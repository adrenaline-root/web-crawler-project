# web-crawler-project

# DESCRIPTION:
  es: web-crawler-project es un pequeña herramienta escrita en GNU bash que, junto con la implementación de psql, obtiene los enlaces encontrados en una determinada url y los almacena en una base de datos. Dicha base de datos esta compuesta por dos tablas: una para las url raíz, y otra para las ramificaciones de dichas urls. El propósito es simple: a medida que el programa se va ejecutando, va -metafóricamente hablando- "mapeando el terreno" web, con el fin de establecer una serie de direcciones por las que navegar en futuras recolecciones de datos.
  
  en: web-crawler-project is a piece of GNU bash code that, together with psql implementation, gather the links found at an specific provided url and stores them into a database. This database holds two tables: one for root urls, and other for its ramifications. Its purpose is simple: collect as many urls possible in order to clear the way for future data collections.
  
 # HOW TO USE IT
  es: 1) Instala psql si no lo tienes instalado.
      2) Crea una base de datos.
      3) Añade las características necesarias a la base de datos que has creado mediante el comando: psql -U tu_usuario el_nombre_de_tu_base_de_datos < web-crawler.sql
      4) Abre una terminal y ejecuta ./web-crawler.sh [OPCION_1=url_objetivo] [OPCION_2=porcentaje de mapeo deseado]
      
  en: 1) Install psql if not installed already.
      2) Create a database
      3) Add the neede requeriments to the database that you just created with the command:  psql -U your_user your_database_name < web-crawler.sql
      4) Open a terminal and run ./web-crawler.sh [OPTION_1=url_target] [OPTION_2=map percentage desired]
 
 
 # LICENCSE
 es: web-crawler-project funciona bajo licencia MIT, por lo que eres totalmente libre para servirte de él cuanto quieras para tus propios proyectos.
 en: web-crawler-project works under MIT license, so feel completely free to use as much as needed in your own projects.
