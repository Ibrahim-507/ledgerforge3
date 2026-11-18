import glob
for p in glob.glob('app/**/*.py', recursive=True):
    s = open(p, encoding='utf-8-sig').read()
    if 'BaseSettings' not in s:
        continue
    if 'extra=' in s or 'extra =' in s:
        print('already has an extra setting in', p)
        continue
    n = s
    if 'SettingsConfigDict(' in s:
        n = s.replace('SettingsConfigDict(', 'SettingsConfigDict(extra="ignore", ', 1)
    elif 'class Config:' in s:
        n = s.replace('class Config:', 'class Config:\n        extra = "ignore"', 1)
    if n != s:
        open(p, 'w', encoding='utf-8', newline='\n').write(n)
        print('fixed', p)
    else:
        print('could not auto-fix', p)
