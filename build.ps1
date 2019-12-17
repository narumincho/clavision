Write-Output "build to tomcat..."

# Get-ChildItem ./src/clavision | ForEach-Object { 
#     Write-Output $_;

#     javac.exe $_ -classpath "C:\Program Files\PostgreSQL\pgJDBC\postgresql-42.2.5.jar;C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\servlet-api.jar;C:\Users\narum\.m2\repository\org\jetbrains\annotations\17.0.0\annotations-17.0.0.jar;" -d "C:/Program Files./Apache Software Foundation/Tomcat 9.0/webapps/clavision/WEB-INF/classes" -encoding utf8;
# }

javac.exe ./src/clavision/Hello.java -classpath "C:\Program Files\PostgreSQL\pgJDBC\postgresql-42.2.5.jar;C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\servlet-api.jar;C:\Users\narum\.m2\repository\org\jetbrains\annotations\17.0.0\annotations-17.0.0.jar;" -d "C:/Program Files./Apache Software Foundation/Tomcat 9.0/webapps/clavision/WEB-INF/classes" -encoding utf8;


Copy-Item ./web.xml 'C:/Program Files/Apache Software Foundation/Tomcat 9.0/webapps/clavision/WEB-INF'

Write-Output "build to tomcat ok!"