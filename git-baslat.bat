# GOCEBE - Git deposu hazirligi
# Bu klasor tek basina bir repo olarak GitHub'a cikarilabilir.

cd /d "%~dp0"
git init -q 2>nul
git add -A
git commit -m "GOCEBE v1.0.0 - site tasima tezgahi (3 yorum zorunlu)" -q 2>nul
git branch -M main 2>nul

echo.
echo  Yerel repo hazir.
echo.
echo  GitHub'a cikarmak icin (gh CLI ile):
echo    gh repo create gocebe --public --source=. --push
echo.
echo  veya mevcut bir depoya:
echo    git remote add origin https://github.com/KULLANICI/gocebe.git
echo    git push -u origin main
pause
