# Dominio: Restaurante "El Buen Sabor"

Sistema de comunicación **mesero ↔ chef** con reservaciones y pedidos en línea.
Una sola sucursal. Diagramas: [modelo-er.webp](modelo-er.webp) y [casos-de-uso.webp](casos-de-uso.webp).

## Fuera de alcance (indicación de la docente)
- Cobros, caja y tickets. "Completado" solo significa que el pedido ya se cerró.
- Control de inventario. `merma_cancelacion` solo alimenta el reporte gerencial.
- Pedidos a domicilio (por ahora solo en mesa y para llevar).

## Roles
| Rol | Qué hace |
|---|---|
| cliente | Se registra, reserva (CU-10/12/13/14; es el único que reserva y confirma), pide en línea para llevar (CU-11), consulta su pedido (CU-08) |
| mesero | Registra pedidos en mesa o para llevar (CU-01/02), modifica/cancela (CU-04/05), consulta (CU-08), consulta reservaciones (solo lectura) |
| chef | Ve comandas (CU-03), actualiza estado (CU-15) |
| gerente | Todo lo anterior salvo tomar pedidos + reporte (CU-07), descuentos/cortesías (CU-09), aprueba o rechaza las solicitudes de cambio del mesero (RN-03) |

Todos usan el mismo login. El personal entra con `usuario` + contraseña (Supabase Auth; internamente
`usuario normalizado@restaurante.local`, p. ej. "Juan Pérez" → `juan.perez@restaurante.local`); los clientes, con su correo.
Los clientes se registran solos (`/registro`); **el registro público siempre crea clientes**.
Solo el gerente crea cuentas de personal (`crear_empleado`, desde Gerencia).
Usuarios de prueba: ver el encabezado de `supabase/seed.sql`.

| Rol | Secciones |
|---|---|
| mesero | Inicio, Reservaciones |
| chef | Inicio, Cocina |
| gerente | Inicio, Reservaciones, Cocina, Gerencia |
| cliente | Inicio ("Mis pedidos"), Reservaciones |

### Modelo de seguridad
- La autorización la decide la base (RLS, triggers y RPC con SECURITY DEFINER); la app solo oculta secciones por comodidad.
- El rol sale de `empleado`/`cliente` por `auth.uid()`, nunca de datos que envíe el cliente (el registro ignora cualquier `rol`).
- `@restaurante.local` está reservado al personal; el registro público lo rechaza.
- Pendiente para producción: confirmación de correo, límites de intentos/CAPTCHA en Auth y MFA para gerentes.

## Estados
- **pedido**: `pendiente → en_preparacion → listo → entregado → completado`, o `cancelado`.
  La app muestra `completado` y `cancelado` en un filtro aparte ("historial").
- **reservacion**: `pendiente → confirmada → completada`, o `cancelada`.
- **mesa**: `libre`, `ocupada`, `reservada` (la cambia el personal).
- **tipo_pedido**: `en_mesa` o `para_llevar`. `origen`: `mesero` o `en_linea`.

## Folios
- `folio_dia`: consecutivo que reinicia cada día (zona `America/Mexico_City`). Es el que ven mesero y chef.
- `folio`: global (PK). Solo se muestra en "más información".

## Reglas de negocio implementadas en la base de datos
- **RN-03**: pedido que ya no está `pendiente` no se modifica ni cancela libremente.
  El cliente pierde la opción. **Corrección acordada por el equipo:** el diagrama original pedía el PIN del gerente
  para el mesero, pero un PIN compartido se puede aprender o prestar. Ahora el mesero **solicita** el cambio
  (`solicitar_cambio(folio, tipo, motivo)`: modificar o cancelar, con motivo) y el **gerente aprueba o rechaza**
  desde su propia sesión (`resolver_solicitud(id, aprobar)`). Al aprobar se abre una ventana de **10 minutos** sobre ese
  pedido (`pedido.autorizado_por` / `autorizacion_hasta`, que ya validaban los triggers y `actualizar_pedido`).
  Solo se solicita sobre pedidos que ya no están pendientes ni cerrados; una sola solicitud pendiente por pedido; sin PIN.
  Tabla `solicitud_cambio` (RLS: solo lectura para mesero y gerente; se escribe únicamente con las RPC) y auditada (RNF-04).
  Toda cancelación crea un registro en `merma_cancelacion` (con el gerente que autorizó) y avisa a cocina.
- **RN-07**: el cliente solo cancela/modifica una reservación con ≥ 5 horas de anticipación (el gerente no tiene esa restricción; el mesero no modifica ni cancela).
- **RNF-04**: `bitacora_auditoria` registra quién (user, rol, empleado) insertó/modificó pedidos, detalles, reservaciones, platillos y mesas.
- **CU-09**: `aplicar_descuento(folio, monto, es_cortesia, motivo)`, solo gerente, sobre el pedido completo. Solo sirve como registro para el reporte.
- Precio congelado en `detalle_pedido.precio_unitario`; `total` se recalcula con triggers.
- Cocina recibe `notificacion_cocina` (`nuevo`, `modificado`, `cancelado`); la app se suscribe por Realtime.

## Cocina (CU-03, CU-06, CU-15)
- Pestaña **Cocina** (chef y gerente). Tablero de los pedidos **de hoy** en tres columnas: Pendiente, En preparación y Listo, los más antiguos primero, con platillos, cantidades, notas, tipo/mesa y minutos transcurridos.
- **Estados:** el chef solo avanza `pendiente → en_preparacion → listo` (trigger `pedido_antes_update`; cualquier otra transición se rechaza). Entregar y completar es del mesero. Un pedido cancelado sale del tablero.
- **Avisos (CU-06):** panel con las `notificacion_cocina` sin atender (`atendida = false`), con botón "Entendido" (uno o todos; el chef solo puede actualizar la columna `atendida`). Solo se listan los avisos de pedidos **de hoy** (los de días anteriores no se arrastran). Si llega un aviso nuevo, el **chef** ve un aviso flotante **en cualquier pestaña** (`AvisosCocinaFlotantes`, en el marco de la app), no solo en Cocina. El gerente ve la pestaña Cocina pero no recibe estos avisos flotantes (son para quien prepara).
- Todo se actualiza por Realtime (`pedido` y `notificacion_cocina`). No hizo falta migración: reglas y permisos ya existían.
- App: `features/cocina`, repositorio `CocinaRepository` (consulta con renglones en una sola petición); el cambio de estado reutiliza `PedidoRepository.actualizarEstado`.

## Menú y comanda
- `platillo.categoria` es una lista fija: Bebidas, Antojitos/Entradas, Platos Fuertes, Postres, Especialidades.
- `platillo.imagen_url` (opcional). Sin imagen, la app muestra un ícono de la categoría.
- `disponible = false` => el platillo se muestra "Agotado", sin botón de agregar (para que el mesero avise al cliente).
- **Mesa automática**: al crear un pedido *en mesa* la mesa pasa a `ocupada`; vuelve a `libre` cuando
  todos sus pedidos en mesa están `completado` o `cancelado`. Se puede pedir en una mesa ya ocupada
  (pedido "extra"). Los pedidos *para llevar* no ocupan la mesa, aunque se asocien a una.
- "Para llevar" admite la casilla **Sin mesa** (marcada por defecto): no asocia mesa.
- **Una sola pantalla de comanda** (`/pedido/nuevo` y `/pedido/:folio/editar`) para crear, editar y para que
  el cliente pida en línea (el cliente no elige mesa ni tipo: siempre es para llevar).
- **Mis pedidos (CU-08, cliente):** el Inicio del cliente lista sus pedidos de hoy (Folio, Hora, Estado, Total), todos los estados, de 5 en 5 y en tiempo real, con el botón "Hacer un pedido". Sin filtros ni Mesa/Tipo. Las acciones son **Editar** y **Cancelar**, visibles solo en pedidos `pendiente` (RN-03). Editar abre la misma comanda (siempre para llevar); Cancelar pide el motivo en un cuadro y cancela al instante (también se puede cancelar desde la comanda). Cuando el pedido pasa a preparación el botón desaparece y la base lo rechaza ("pide ayuda al mesero"). La política `pedido_select` ya solo le devuelve los suyos y `actualizar_pedido`/`pedido_antes_update` ya exigían estas reglas; no hizo falta migración.
- El mismo platillo con la misma nota suma cantidad; con otra nota es un renglón aparte. Notas de hasta 200 caracteres.
- `actualizar_pedido(folio, tipo, mesa, items)` reemplaza los renglones de forma atómica y avisa **una vez** a cocina.
  Mismas reglas que RN-03: mesero solo si está `pendiente` (o con una solicitud aprobada y vigente), cliente solo el suyo y `pendiente`.
  El **gerente** edita y cancela en cualquier estado salvo `completado`/`cancelado`; en la Comandería ve "Editar" en pendiente, en preparación y listo (no en entregado).
- **Solicitudes de cambio (RN-03, app):** el mesero ve "Solicitar cambio" en los pedidos en preparación o listos; elige Modificar o Cancelar, escribe el motivo y la fila queda en "Solicitud enviada". El gerente ve arriba de la Comandería el panel "Solicitudes de cambio pendientes" (mesero, pedido, tipo, motivo) con **Aprobar** / **Rechazar**, y un aviso flotante cuando llega una nueva. Al aprobar, el mesero recibe un aviso, ve "Editar" en ese pedido y tiene 10 minutos para editarlo o cancelarlo; si vence, debe solicitar de nuevo. Un rechazo avisa al mesero y permite volver a solicitar. Código en `features/solicitudes`, repositorio `SolicitudRepository`, migración `20261112200000_solicitudes_de_cambio.sql` (que también quita `autorizar_con_pin` y `establecer_pin`; la tabla `gerente_pin` queda sin uso).
- Cancelar desde la pantalla de edición exige motivo y crea el registro en `merma_cancelacion`.

## Reservaciones (diseño propio, simple)
- La mesa se **asigna automáticamente**: la de menor capacidad que alcance y no se empalme. Se supone una duración de **2 horas** por reservación.
- **Quién puede qué:** **solo el cliente crea** reservaciones (con 5 h o más de anticipación; nacen `pendiente`), y también modifica (vuelve a `pendiente`), cancela y **confirma** las suyas, todo con la ventana de 5 h (RN-07). El **mesero solo consulta**: no crea, modifica, cancela ni confirma. El **gerente modifica y cancela** las de los clientes sin límite de tiempo, pero no crea ni confirma por el cliente. Las reglas están en RLS y en `reservacion_validar()`.
- **Confirmación:** el cliente confirma antes de que se cierre la ventana de 5 h. Si llega a las 5 h sin confirmar queda "sin confirmar" y la mesa se libera sola. No hay tareas programadas: se calcula al consultar. La vista `reservaciones_por_confirmar` lista esas reservaciones para que el personal pueda llamar al cliente.
- **Aviso al cliente:** cuando a una reservación le faltan 5 h o menos, la app abierta muestra un aviso flotante (`AvisosReservaciones`). No hay correo ni SMS (requiere un servicio externo).
- Las reglas viven en `reservacion_validar()` y en las políticas `reservacion_insert`/`reservacion_update` (migraciones `20261110200000_reservaciones_roles_y_confirmacion.sql` y `20261110220000_reservaciones_solo_cliente_y_gerente.sql`).
- **Pantalla** (`features/reservaciones`): lista con filtro, tiempo real y un formulario único para crear (cliente) y modificar (cliente y gerente). Diseño provisional sin Figma.

## Contrato con la app (Flutter)
- Crear pedido: `supabase.rpc('crear_pedido', params: {p_tipo_pedido, p_id_mesa, p_items})`. **Solo mesero y cliente** crean pedidos; el gerente supervisa (migración `20261112120000_pedidos_gerente_no_crea.sql`) y el chef no.
- En la Comandería, los pedidos en línea muestran bajo el folio el **nombre del cliente** (si el rol puede leerlo: mesero y gerente; el chef ve "En línea" por RLS de `cliente_select`) y el buscador también lo encuentra.
  con `p_items = [{id_platillo, cantidad, notas_especiales}]`. No se inserta directo en `pedido`.
- Cambiar estado / cancelar: `update` sobre `pedido` (cancelar exige `motivo_cancelacion`).
- Los errores de reglas llegan como `PostgrestException` con mensaje en español listo para mostrar.
- `empleado` se lee con `select()` normal.
- Solicitudes de cambio: `rpc('solicitar_cambio', {p_folio, p_tipo, p_motivo})` (mesero) y `rpc('resolver_solicitud', {p_id, p_aprobar})` (gerente).
- Sin sesión solo se puede leer `platillo` (menú).

## Pendiente / decisiones abiertas
- Vistas/funciones del reporte gerencial (CU-07): se definen al ver la pantalla en Figma.
