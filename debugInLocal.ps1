Copy-Item source/assets dist/ -Recurse;
npx.ps1 parcel source/index.html --open;
