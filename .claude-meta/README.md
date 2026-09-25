# claude-meta

Persistence Claude artefaktů (`CLAUDE.md`, `.claude/` – agenti, skilly,
nastavení, paměti…) **mimo master**, aby se daly upstreamovat změny bez
jakýchkoli Claude souborů.

## Jak to funguje

- Artefakty žijí na **orphan větvi `claude-meta`** (nemá společnou historii
  s masterem, takže ji nejde omylem tiše mergnout – git ohlásí "unrelated
  histories"). Nikdy se nemerguje do masteru ani do feature větví.
- `bootstrap.sh` zkopíruje artefakty z `origin/claude-meta` do pracovní
  kopie (jen soubory, nesahá na index) a zapíše je do `.git/info/exclude`.
  Ten je čistě lokální (necommituje se), takže `git status` i `git add -A`
  je na pracovních větvích trvale ignorují.
- `save.sh` změny artefaktů commitne zpět na `claude-meta` a pushne –
  přes dočasný worktree, bez přepínání aktuální větve.

Master tedy zůstává bez jediné Claude stopy (`.claude/` už mimochodem
ignoruje `.gitignore` zděděný z upstreamu; `CLAUDE.md` a `.claude-meta/`
kryje `.git/info/exclude`).

## Bootstrap v nové session / novém klonu

```sh
git fetch --depth 1 origin +refs/heads/claude-meta:refs/remotes/origin/claude-meta
git show origin/claude-meta:.claude-meta/bootstrap.sh | bash
```

Pro cloudové sessions (claude.ai/code) vlož tyto dva řádky do **Setup
scriptu** prostředí (menu prostředí v titulku session → Edit → Setup
script), ať se artefakty obnoví automaticky při startu každé session.

## Uložení změn

Po každé úpravě agentů, pamětí nebo `CLAUDE.md`:

```sh
.claude-meta/save.sh "chore: co se změnilo"
```

(Claude to udělá sám – má to jako instrukci v `CLAUDE.md`.)

## Přidání další persistované cesty

Přidej řádek do `.claude-meta/manifest` (cesta od kořene repa, bez
lomítka na konci), spusť `save.sh` a příště `bootstrap.sh`.

## Poznámky

- Jinou větev lze zvolit přes `CLAUDE_META_BRANCH=<název>` u obou skriptů.
- Když push v `save.sh` selže (někdo mezitím pushnul), spusť ho znovu –
  fetchne si čerstvou špičku větve.
- Smazané soubory: `bootstrap.sh` jen přidává/přepisuje; když artefakt
  smažeš na větvi, ve starších pracovních kopiích může zůstat ležet.
