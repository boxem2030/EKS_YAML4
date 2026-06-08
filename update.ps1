$Region = "ap-northeast-2"
$File   = ".\ingress.yaml"

# host 입력
$NewHost = Read-Host "새로운 host 입력 (예: www.example.com)"

# ACM에서 첫 번째 인증서 ARN 조회
$Arn = (aws acm list-certificates `
  --region $Region `
  --query "CertificateSummaryList[0].CertificateArn" `
  --output text).Trim()

if (-not $Arn -or $Arn -eq "None") {
  Write-Host "ACM 인증서를 찾지 못했습니다." -ForegroundColor Red
  exit 1
}

# 파일 읽기
$Content = [System.IO.File]::ReadAllText($File)

# spec.rules.host 변경
$Content = [regex]::Replace(
  $Content,
  '(?m)^(\s*-\s*host:\s*).*$',
  "`$1$NewHost"
)

# external-dns hostname 변경
$Content = [regex]::Replace(
  $Content,
  '(?m)^(\s*external-dns\.alpha\.kubernetes\.io/hostname:\s*).*$',
  "`$1$NewHost"
)

# certificate-arn 변경
$Content = [regex]::Replace(
  $Content,
  '(?m)^(\s*alb\.ingress\.kubernetes\.io/certificate-arn:\s*).*$',
  "`$1$Arn"
)

# 저장
[System.IO.File]::WriteAllText($File, $Content)

Write-Host "host 변경 완료: $NewHost" -ForegroundColor Green
Write-Host "external-dns hostname 변경 완료: $NewHost" -ForegroundColor Green
Write-Host "certificate-arn 변경 완료: $Arn" -ForegroundColor Green