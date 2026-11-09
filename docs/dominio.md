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
| cliente | Se registra, reserva (CU-10/12/13/14), pide en línea para llevar (CU-11), consulta su pedido (CU-08) |
| mesero | Registra pedidos en mesa o para llevar (CU-01/02), modifica/cancela (CU-04/05), consulta (CU-08), gestiona reservaciones |
| chef | Ve comandas (CU-03), actualiza estado (CU-15) |
| gerente | Todo lo anterior + reporte (CU-07), descuentos/cortesías (CU-09), PIN de autorización |

Todos usan el mismo login. El personal entra con `usuario` + contraseña (Supabase Auth; internamente
`usuario normalizado@restaurante.local`, p. ej. "Juan Pérez" → `juan.perez@restaurante.local`); los clientes, con su correo.
Los clientes se registran solos (`/registro`); **el registro público siempre crea clientes**.
Solo el gerente crea cuentas de personal (`crear_empleado`, desde Gerencia).
Usuarios de prueba: ver el encabezado de `supabase/seed.sql`.

| Rol | Secciones |
|---|---|
| mesero | Inicio |
| chef | Inicio, Cocina |
| gerente | Inicio, Cocina, Gerencia |
| cliente | Inicio |

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
  El cliente pierde la opción; el mesero debe llamar `autorizar_con_pin(folio, pin)` (PIN de un gerente,
  válido 10 min). Toda cancelación crea un registro en `merma_cancelacion` y avisa a cocina.
- **RN-07**: el cliente solo cancela/modifica una reservación con ≥ 5 horas de anticipación (el personal no tiene esa restricción).
- **RNF-04**: `bitacora_auditoria` registra quién (user, rol, empleado) insertó/modificó pedidos, detalles, reservaciones, platillos y mesas.
- **CU-09**: `aplicar_descuento(folio, monto, es_cortesia, motivo)`, solo gerente, sobre el pedido completo. Solo sirve como registro para el reporte.
- Precio congelado en `detalle_pedido.precio_unitario`; `total` se recalcula con triggers.
- Cocina recibe `notificacion_cocina` (`nuevo`, `modificado`, `cancelado`); la app se suscribe por Realtime.

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
- El mismo platillo con la misma nota suma cantidad; con otra nota es un renglón aparte. Notas de hasta 200 caracteres.
- `actualizar_pedido(folio, tipo, mesa, items)` reemplaza los renglones de forma atómica y avisa **una vez** a cocina.
  Mismas reglas que RN-03: mesero solo si está `pendiente` (o con PIN autorizado), cliente solo el suyo y `pendiente`.
- Cancelar desde la pantalla de edición exige motivo y crea el registro en `merma_cancelacion`.

## Reservaciones (diseño propio, simple)
- La mesa se **asigna automáticamente**: la de menor capacidad que alcance y no se empalme.
  Se supone una duración de **2 horas** por reservación.
- Se crea `pendiente`. Cuando faltan ≤ 5 h, la vista `reservaciones_por_confirmar` la lista y la app del
  cliente muestra "¿Confirmas tu reservación?" → el cliente la pasa a `confirmada`.
- Dentro de esas 5 h el cliente ya no puede cancelar ni modificar (RN-07), solo confirmar.
- Si el cliente modifica fecha/hora/comensales, vuelve a `pendiente` y se reasigna mesa.
- No hay cancelación automática por falta de confirmación (requeriría tareas programadas; fuera de alcance).
- **Quién hace qué:** el cliente reserva, consulta, modifica y cancela las suyas (CU-10/12/13/14) y solo ve su
 reservación, sin mesa. El mesero y el gerente ven todas (con mesa y cliente), pueden crear a nombre de un
 cliente (existente o nuevo, sin cuenta), modificar y cancelar sin el límite de 5 h. El chef no accede.
- **Pantalla** (`features/reservaciones`, pestaña "Reservaciones"): lista con filtro Próximas / Historial / Todas,
tiempo real, confirmar y cancelar con burbuja de confirmación, y un formulario único (fecha, hora, comensales)
para crear y modificar. La mesa nunca se elige: la asigna la base. Diseño provisional sin Figma.
- El repositorio (`ReservacionRepository`) escribe directo en `reservacion` y `cliente`; las reglas (mesa
disponible, RN-07, fecha futura) las valida el trigger `reservacion_validar` y el mensaje llega en español.

## Contrato con la app (Flutter)
- Crear pedido: `supabase.rpc('crear_pedido', params: {p_tipo_pedido, p_id_mesa, p_items})`
  con `p_items = [{id_platillo, cantidad, notas_especiales}]`. No se inserta directo en `pedido`.
- Cambiar estado / cancelar: `update` sobre `pedido` (cancelar exige `motivo_cancelacion`).
- Los errores de reglas llegan como `PostgrestException` con mensaje en español listo para mostrar.
- `empleado` se lee con `select()` normal; el PIN está en otra tabla inaccesible.
- Sin sesión solo se puede leer `platillo` (menú).

## Pendiente / decisiones abiertas
- Vistas/funciones del reporte gerencial (CU-07): se definen al ver la pantalla en Figma.
- Intentos fallidos de PIN no tienen límite (aceptable para el alcance escolar).
