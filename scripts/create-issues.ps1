# Crée les issues GitHub du backlog (docs/tasks-backlog.md) via le CLI gh.
#
# Prérequis (une seule fois) :
#   1. Installer gh          : winget install --id GitHub.cli
#   2. Ouvrir un NOUVEAU terminal (pour recharger le PATH)
#   3. S'authentifier        : gh auth login   (suivre le flux navigateur)
#
# Puis, depuis la racine du repo :
#   pwsh scripts/create-issues.ps1
#
# Le script est idempotent par titre : il saute une issue déjà existante.

$ErrorActionPreference = 'Stop'
$repo = 'DorianMuzi/LinguaCE'

# S'assure que les labels existent (ignore l'erreur si déjà présents).
$labels = @(
  @{ name = 'priority: high';   color = 'b60205' },
  @{ name = 'priority: medium'; color = 'fbca04' },
  @{ name = 'priority: low';    color = '0e8a16' },
  @{ name = 'accessibility';    color = '5319e7' },
  @{ name = 'phase-3';          color = '1d76db' },
  @{ name = 'discussion';       color = 'cccccc' }
)
foreach ($l in $labels) {
  try { gh label create $l.name --color $l.color --repo $repo 2>$null } catch {}
}

# Titres + labels + corps de chaque issue. Les corps sont volontairement
# courts ici : le détail complet vit dans docs/tasks-backlog.md.
$issues = @(
  @{
    title  = 'Notifications de rappel quotidien'
    labels = 'enhancement,priority: high,good first issue'
    body   = "Planifier une notification locale quotidienne pour soutenir la serie ; brancher le toggle set.notifications existant ; permission Android 13+ ; pas de rappel si deja actif (last_activity).`n`nDetail complet + criteres d'acceptation : docs/tasks-backlog.md (section 1)."
  },
  @{
    title  = "Passe d'accessibilite (contraste + lecteurs d'ecran)"
    labels = 'accessibility,priority: medium,good first issue'
    body   = "textTertiary sous le seuil WCAG AA ; emojis-icones lus litteralement. Corriger le contraste et ajouter des Semantics.`n`nDetail complet + criteres d'acceptation : docs/tasks-backlog.md (section 2)."
  },
  @{
    title  = "Animation de gain d'XP dans les exercices"
    labels = 'enhancement,priority: low,good first issue'
    body   = "Recompense visuelle '+10 XP' au moment du gain (exercise_screen.dart), en respectant reduced motion.`n`nDetail complet + criteres d'acceptation : docs/tasks-backlog.md (section 3)."
  },
  @{
    title  = 'Deep link de reinitialisation du mot de passe'
    labels = 'bug,priority: medium'
    body   = "Le retour vers l'app depuis l'email de reset n'est pas valide sur device (redirectTo Supabase + intent filter Android).`n`nDetail complet + criteres d'acceptation : docs/tasks-backlog.md (section 4)."
  },
  @{
    title  = "Refonte des actions rapides de l'accueil"
    labels = 'enhancement,priority: low,discussion'
    body   = "Les actions rapides de l'accueil dupliquent la nav bar. Les remplacer par des actions a valeur unique (a discuter dans l'issue).`n`nDetail complet + criteres d'acceptation : docs/tasks-backlog.md (section 5)."
  },
  @{
    title  = '[GROS CHANTIER] Contenu des lecons en base Supabase'
    labels = 'enhancement,priority: high,help wanted,phase-3'
    body   = "Les exercices sont codes en dur (exercise_screen.dart, lecons 1-6) ; toute lecon au-dela de la 6 ouvre un ecran qui se referme. Migrer vers une table Supabase + ExerciseService avec repli hors-ligne. Verrou de la Phase 3.`n`nNE PAS modifier le contenu tchetchene a cette occasion (cf. docs/audit-linguistique-2026-06-11.md).`n`nDetail complet + criteres d'acceptation : docs/tasks-backlog.md (section 6)."
  }
)

foreach ($i in $issues) {
  $exists = gh issue list --repo $repo --search $i.title --state all --json title `
    | ConvertFrom-Json | Where-Object { $_.title -eq $i.title }
  if ($exists) {
    Write-Host "SKIP (existe deja) : $($i.title)" -ForegroundColor Yellow
    continue
  }
  gh issue create --repo $repo --title $i.title --body $i.body --label $i.labels
  Write-Host "CREEE : $($i.title)" -ForegroundColor Green
}

Write-Host "`nTermine. Issues : https://github.com/$repo/issues"
