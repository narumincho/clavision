Write-Output "build to tomcat...";

Remove-Item "C:/Program Files/Apache Software Foundation/Tomcat 9.0/webapps/clavision/*" -Recurse

Remove-Item "static/*" -Recurse

Push-Location ./src;

javac.exe ./clavision/Api.java -classpath "C:/Program Files/PostgreSQL/pgJDBC/postgresql-42.2.5.jar;C:/Program Files/PostgreSQL/pgJDBC/postgresql-42.2.5.jre6.jar;C:/Program Files/PostgreSQL/pgJDBC/postgresql-42.2.5.jre7.jar;C:/Program Files/Apache Software Foundation/Tomcat 9.0/lib/servlet-api.jar;C:\Users\narum\.m2\repository\org\jetbrains\annotations\17.0.0\annotations-17.0.0.jar;" -d "C:/Program Files/Apache Software Foundation/Tomcat 9.0/webapps/clavision/WEB-INF/classes" -encoding utf8;

Pop-Location;

npx.ps1 parcel build clientSource/index.html --out-dir static --public-url /clavision/ --no-source-maps

Get-ChildItem -Path "static" | ForEach-Object { Copy-Item -Path $_ "C:/Program Files/Apache Software Foundation/Tomcat 9.0/webapps/clavision" }

Write-Output "build to tomcat ok!"
