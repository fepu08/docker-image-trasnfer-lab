#!/bin/bash
set -e

REPOSITORY_NAME="docker-image-transfer/test"
IMAGE_TAG="latest"
AWS_REGION="eu-central-1"
ACCOUNT_NUM=

# Parse args: support -a/--account or single positional argument
usage() {
  cat <<EOF
Usage: $0 [-a ACCOUNT] [ACCOUNT]

Options:
  -a, --account   12-digit AWS account number to use for ECR (overrides default)
  -h, --help      Show this help
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--account)
      if [[ -n "$2" ]]; then
        ACCOUNT_NUM="$2"
        shift 2
      else
        echo "Error: --account requires a value" >&2
        usage
      fi
      ;;
    -h|--help)
      usage
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      # positional argument: account number
      if [[ -n "$1" ]]; then
        ACCOUNT_NUM="$1"
        shift
      else
        shift
      fi
      ;;
  esac
done

# Validate ACCOUNT_NUM is a 12-digit number
if ! [[ "$ACCOUNT_NUM" =~ ^[0-9]{12}$ ]]; then
  echo "Error: ACCOUNT_NUM must be a 12-digit AWS account number. Got: $ACCOUNT_NUM" >&2
  exit 2
fi

FULL_IMAGE_NAME="${ACCOUNT_NUM}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}:${IMAGE_TAG}"
REGISTRY_URL="${ACCOUNT_NUM}.dkr.ecr.${AWS_REGION}.amazonaws.com"

LOCAL_DIGEST=$(docker inspect --format='{{if gt (len .RepoDigests) 0}}{{index (split (index .RepoDigests 0) "@") 1}}{{else}}{{.Id}}{{end}}' "$FULL_IMAGE_NAME" 2>/dev/null || true)
echo LOCAL DIGEST ${LOCAL_DIGEST}

# Handle missing local image
if [ -z "$LOCAL_DIGEST" ]; then
  echo "📥 Local image not found — pulling from ECR..."
  aws ecr get-login-password --region $AWS_REGION \
    | docker login --username AWS --password-stdin $REGISTRY_URL

  docker pull ${REGISTRY_URL}/${REPOSITORY_NAME}:${IMAGE_TAG}
  exit 0
fi

# Compare digests
if [ "$LOCAL_DIGEST" = "$REMOTE_DIGEST" ]; then
  echo "✅ Local image matches remote image"
else
  echo "🔄 Local image differs from remote — pulling from ECR..."
  aws ecr get-login-password --region $AWS_REGION \
    | docker login --username AWS --password-stdin $REGISTRY_URL

  docker pull ${REGISTRY_URL}/${REPOSITORY_NAME}:${IMAGE_TAG}
fi
