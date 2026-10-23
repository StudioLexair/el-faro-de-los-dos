#!/usr/bin/env python3
"""Package a CI-built APK and the static site for Vercel Build Output API.

This script never compiles Flutter. GitHub Actions supplies the signed APK.
No tokens or signing material are copied into the web deployment.
"""
from pathlib import Path
from datetime import datetime, timezone
import argparse, hashlib, json, os, re, shutil

parser=argparse.ArgumentParser()
parser.add_argument('--apk',required=True,type=Path)
parser.add_argument('--output',default='.vercel/output',type=Path)
args=parser.parse_args()
root=Path(__file__).resolve().parents[1]
apk=args.apk.resolve()
if not apk.is_file() or apk.stat().st_size < 1_000_000:
    raise SystemExit('Falta un APK compilado válido; no se publicará una descarga vacía.')
with apk.open('rb') as f:
    if f.read(2)!=b'PK':raise SystemExit('El archivo suministrado no es un APK/ZIP.')
match=re.search(r'^version:\s*([^\s+]+)\+(\d+)',(root/'pubspec.yaml').read_text(),re.M)
if not match:raise SystemExit('No se puede leer la versión de pubspec.yaml')
version,build_number=match.groups()
output=args.output.resolve()
if output in [root, root/'site', Path('/')]:raise SystemExit('Directorio de salida no válido')
if output.exists():shutil.rmtree(output)
static=output/'static'
shutil.copytree(root/'site',static)
(static/'downloads').mkdir()
filename='El-Faro-de-los-Dos-Android.apk'
shutil.copy2(apk,static/'downloads'/filename)
hash_value=hashlib.file_digest(apk.open('rb'),'sha256').hexdigest()
metadata={
 'available':True,'name':'El Faro de los Dos','version':version,'buildNumber':int(build_number),
 'filename':filename,'apkUrl':'/downloads/'+filename,'sizeBytes':apk.stat().st_size,
 'sha256':hash_value,'minimumAndroid':'7.0','minimumSdk':24,
 'architectures':['ARM de 32 bits','ARM de 64 bits'],
 'builtAt':datetime.now(timezone.utc).isoformat(),'commit':os.environ.get('GITHUB_SHA',''),
 'repositoryUrl':'https://github.com/'+os.environ.get('GITHUB_REPOSITORY','StudioLexair/el-faro-de-los-dos'),
 'workflowUrl':'https://github.com/'+os.environ.get('GITHUB_REPOSITORY','StudioLexair/el-faro-de-los-dos')+'/actions',
 'buildOrigin':'GitHub Actions',
}
(static/'download.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2)+'\n')
(static/'downloads/SHA256SUMS.txt').write_text(hash_value+'  '+filename+'\n')
config={'version':3,'routes':[
 {'src':'/(.*)','headers':{'X-Content-Type-Options':'nosniff','Referrer-Policy':'strict-origin-when-cross-origin',
   'Permissions-Policy':'camera=(), microphone=(), geolocation=()',
   'Content-Security-Policy':"default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; font-src 'self'; connect-src 'self'; object-src 'none'; base-uri 'none'; form-action 'none'"},'continue':True},
 {'src':'/downloads/(.*\\.apk)','headers':{'Content-Type':'application/vnd.android.package-archive',
   'Content-Disposition':'attachment; filename="'+filename+'"',
   'Cache-Control':'public, max-age=0, must-revalidate'},'continue':True},
 {'src':'/download.json','headers':{'Cache-Control':'no-store'},'continue':True},
 {'src':'/','headers':{'Cache-Control':'public, max-age=0, must-revalidate'},'continue':True},
 {'handle':'filesystem'},
 {'src':'/(.*)','dest':'/404.html','status':404},
]}
(output/'config.json').write_text(json.dumps(config,indent=2)+'\n')
print(json.dumps({'version':version,'bytes':metadata['sizeBytes'],'sha256':hash_value,
 'output':str(output),'buildOrigin':'GitHub Actions'},indent=2))
