FROM ubuntu:20.04

# 비대화형 모드 설정 및 필수 패키지 설치
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    libicu-dev \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 시간대 설정 (예: Asia/Seoul)
RUN ln -fs /usr/share/zoneinfo/Asia/Seoul /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

# GitHub Actions Runner 다운로드 및 설치
RUN mkdir -p /actions-runner
WORKDIR /actions-runner
RUN curl -o actions-runner-linux-x64-2.317.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz\
    && tar xzf ./actions-runner-linux-x64-2.317.0.tar.gz \
    && rm ./actions-runner-linux-x64-2.317.0.tar.gz

# Dotnet Core 3.0 종속성 설치
RUN ./bin/installdependencies.sh

# 비루트 사용자 생성
RUN useradd -m runner
RUN chown -R runner:runner /actions-runner

USER runner

# Runner 설정 및 실행
CMD ./config.sh --url $REPO_URL --token $RUNNER_TOKEN --name $RUNNER_NAME --work $RUNNER_WORKDIR --labels $LABELS --unattended --replace && ./run.sh