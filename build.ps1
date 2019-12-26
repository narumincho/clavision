Write-Output "build to tomcat...";

javac.exe ./src/clavision/Api.java -classpath "C:\Program Files\PostgreSQL\pgJDBC\postgresql-42.2.5.jar;C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\servlet-api.jar;C:\Users\narum\.m2\repository\org\jetbrains\annotations\17.0.0\annotations-17.0.0.jar;" -d "C:/Program Files/Apache Software Foundation/Tomcat 9.0/webapps/clavision/WEB-INF/classes" -encoding utf8;

Get-ChildItem -Path "static" | % { Copy-Item -Path $_ "C:/Program Files/Apache Software Foundation/Tomcat 9.0/webapps/clavision" }

Write-Output "build to tomcat ok!"