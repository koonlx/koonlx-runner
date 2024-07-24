FROM ubuntu:20.04

# 비대화형 모드 설정 및 필수 패키지 설치
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# GitHub Actions Runner 다운로드 및 설치
RUN mkdir -p /actions-runner
WORKDIR /actions-runner
RUN /bin/bash -c 'LATEST_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r ".tag_name") && \
    curl -f -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/${LATEST_VERSION}/actions-runner-linux-x64-${LATEST_VERSION:1}.tar.gz'
RUN tar xzf ./actions-runner-linux-x64.tar.gz
RUN rm ./actions-runner-linux-x64.tar.gz

# Dotnet Core 6.0 종속성 설치
RUN ./bin/installdependencies.sh

# 비루트 사용자 생성
RUN useradd -m runner
RUN chown -R runner:runner /actions-runner

USER runner

# Runner 설정 및 실행
CMD if [ ! -f /actions-runner/.runner ]; then \
        ./config.sh --url $REPO_URL --token $RUNNER_TOKEN --name $RUNNER_NAME --work $RUNNER_WORKDIR --labels $LABELS --unattended --replace && \
        touch /actions-runner/.runner; \
    fi && ./run.sh