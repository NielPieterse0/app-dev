$ErrorActionPreference = "Stop"

$steps = @(
  @{
    Name = "Check workspace structure"
    Action = { & ./scripts/check-workspace.ps1 }
  },
  @{
    Name = "Validate Codex assets"
    Action = { & ./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true }
  },
  @{
    Name = "Test hook policy"
    Action = { & ./scripts/test-hooks.ps1 }
  },
  @{
    Name = "Test workflow enforcement"
    Action = { & ./scripts/test-workflow-enforcement.ps1 }
  },
  @{
    Name = "Test spec analysis"
    Action = { & ./scripts/test-analyze-spec.ps1 }
  },
  @{
    Name = "Check template parity"
    Action = { & ./scripts/check-template-parity.ps1 }
  },
  @{
    Name = "Scan for secrets"
    Action = { & ./scripts/scan-secrets.ps1 }
  },
  @{
    Name = "Test project generation"
    Action = { & ./scripts/test-workspace.ps1 }
  }
)

foreach ($step in $steps) {
  Write-Host "==> $($step.Name)"
  & $step.Action
}

Write-Host "Full governance check passed."
