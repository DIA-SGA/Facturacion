# Tablero-Expediente de pago a proveedpores
Seguimiento de expedientes que tramitan facturas

# Objetivos y alcances:

En el armado de este tablero participó la Dirección de Innovación Administrativa a través de la obtención de distintos formularios controlados obtenidos del GDE y de la recaudación de los trámites a distancia (TAD) para el pago de facturas de proveedores del Ministerio de Salud. 
Las áreas involucradas y destinatarias son aquellas con el interés de visualizar los expedientes abiertos de pago a proveedores. La aprobación de este tablero fue llevada a cabo por la Secretaría de Gestión Administrativo con el fin de visibilizar y trasparentar tanto los tiempos y la cantidad de expedientes, como así también el monto total de las facturas a devengar. Esto permite tener información clara para las distintas áreas del ministerio como para el análisis de comparación con otros ministerios. 

El tablero tiene como objetivo revelar ciertos indicadores importantes y que funcione como repositorio de información sobre los expedientes que se inician por TAD para el pago a proveedores. Para tal fin se hace una actualización semanal, que será estipulado un día fijo. No están incluidos en este tablero aquellos expedientes que ya fueron devengados y cerrados. 

El tablero visualiza indicadores que refieren el importe según la ubicación de los expedientes; el importe según el sistema de origen de pago; el estado de los expedientes; la cantidad de expedientes por estado; los proveedores con mayor importe de facturas.
Además, permite el alcance a una tabla que resume según la repartición donde se ubica el expediente, la cantidad de facturas que tiene esa área, el promedio de días del último pase y el monto total de las facturas. 
Por último, le sigue una pestaña en el que está el listado completo de expedientes abiertos que tramitan el pago de facturas a proveedores.

# Descripción de informes fuente

El tablero de Expedientes de pago a proveedores se construye con cuatro informes de Tableau:
1 “Comprobantes para autogestión de proveedores”
2 “Presentación de facturas Adquisiciones con Financiamiento Internacional”
3 “Presentación de facturas no amparadas por proceso de compra”
4 “Detalle de expedientes GDE – Expedientes electrónicos”
5 “Documentos asociados a expedientes”


**Hasta acá levantamos 4 tablas que salen de comprar que interopera con GDE porque ambos sistemas están vinculados**

## Bajamos los expedientes que no tramitan por el sistema COMPRAR sino por finaciamiento externo *etapa pre comprar*

En [tableau](https://reportes.gob.ar) **tramitaciones y registros** > **GDE expedientes electrónicos** > **Detalles de expedientes** > ir a vista original y seleccionar *detallesSCOyTRAM_EEy COMPRAR* de esta tabla sale fecha de último pase usuario actual repartición actual y fecha de caratulación, son 
datos muy relevantes de un expediente sobre los tiempos de movimiento (donde está, cuánto hace que no se mueve).

En [tableau](https://reportes.gob.ar) **tramitaciones y registro** > *GDE Documentos asociados a expedientes*, *este que no tiene año y tiene estrellita es 2021*
y *GDE Documentos asociados a expedientes 2020* es otro que hay que bajar, que también tiene estrellita. Cada uno de estos dos reportes tiene
dos tablas asociadas, solo hay que bajar una de ellas. En el caso de *GDE Documentos asociados a expedientes 2020* Ir a vista original y bajar 
*Acronimos 2020´*, que es el único reporte que tiene guardado....y me va a llevar a dos tablas de las cuáles solo tengo que bajar una sola, la que está
abajo. Hay que pinchar sobre el encabezado de la tabla de abajo y bajarla...cuándo se descarga hay que agregarle el año porque no lo tiene. Esto hay que repetirlo para
*GDE Documentos asociados 2021* y *GDE Documentos asociados 2022*.

## FORMULARIO FOWMC ##

En [tableau](https://reportes.gob.ar) en **Formularuos controlados** > *Monitoreo del plan anual de compras -SGA#MS*, y desfiltrar todo Expedientes con las documentaciones asociadas a cada uno de ellos, el campo que tenemos que tomar es *Número de expediente*, hay otro que se llama *Expediente donde se encuentra vinculado el formulario FOWMC*, que se va a quitar.
