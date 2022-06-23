# Tablero-Adquisiciones
Seguimiento de expedientes que tramitan adquisiciones

# Solicitudes de contratación tiene tres tablas asociadas:

En [tableau](https://reportes.gob.ar) **compras y contrataciones** > **comprar-informacion general** > entrar **detalles solicitudes de contratación** > bajar las tres tablas que están **detalles de solicitudes de contratación** que se generan desde la platafora de comprar para dar comienzo a una slicitud de contratación, un bien a requerir, que puede o no estar asociada a un proceso de adquisción. Esta tabla tiene la información de un paso previo. Todas las variables vienen de la plataforma electrónica comprar. *Unidad solicitante* es texto libre por lo cual no lo usamos. Monto si nos interesa y la fecha creación y fecha autorización. En la tabla **información prespuestaria** se consolida la información de cada solicitud de contratación, que se repite tantas imputaciones de ejercicio tenga (más de un año). En la tabla **Expedientes asociados** tenemos el número de expediente por el cuál se está actuando sobre las solicitudes de contratación...en esta tabla se guarda la relación del expediente caratulado como SGA en un principio y luego cuándo llega a comprar se lo caratula con la sigla DCYC.

# Detalles porcesos de compra 

En [tableau](https://reportes.gob.ar) **detalles procesos de compra**  hay una sola tabla donde tenemos los estados de los procesos de compra, vincular la solicitud de contratacion y elaboración de pliego, luego está la publicación del pliego. Los estados de los procesos son *inicial*, *publicacion*, *llamado/publicación*, *apertura*, *evaluación de ofertas*, *preadjudicación* y *adjudicación*, esta última es cuando  está el contrato firmado. No miramos los procesos en estado *sin efecto*, *desierto*, *fracasada*, que es cuando alguien se presentó pero el comité de evaluación no aprobó por alguna razón.

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