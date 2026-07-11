@echo off
echo =========================================
echo Compilando aplicacion web...
echo =========================================
call flutter build web --release --no-tree-shake-icons
if %errorlevel% neq 0 (
    echo Error durante la compilacion.
    pause
    exit /b %errorlevel%
)

echo =========================================
echo Subiendo compilado a la rama web_deploy...
echo =========================================
cd build\web
git init
git remote add origin https://github.com/ccamilor/super_motos.git
git checkout -b web_deploy
git add .
git commit -m "Deploy: Manual update"
git push -f origin web_deploy
cd ..\..

echo =========================================
echo Despliegue completado con exito!
echo =========================================
pause
