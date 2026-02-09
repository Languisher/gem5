# ---------- Stage 1: build ----------
FROM ubuntu:22.04 AS builder
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git m4 scons \
    zlib1g zlib1g-dev \
    python3 python3-dev python3-pip \
    libprotobuf-dev protobuf-compiler \
    libssl-dev pkg-config \
    libcapstone-dev \
    ninja-build \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src/gem5

# 把 gem5 源码拷进来（因此 Dockerfile 必须在 gem5/ 目录下 build）
COPY . /src/gem5

# Python 依赖
RUN python3 -m pip install --upgrade pip \
 && python3 -m pip install -r requirements.txt

# 编译目标：RISCV（你也可以换成 X86/ARM）
RUN scons build/RISCV/gem5.opt -j"$(nproc)"

# ---------- Stage 2: runtime ----------
FROM ubuntu:22.04 AS runtime
ARG DEBIAN_FRONTEND=noninteractive

# 运行时通常只需要 python3（看你 configs 脚本是否依赖更多库）
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# 只拷贝编译产物（最小化镜像体积）
COPY --from=builder /src/gem5/build/RISCV/gem5.opt /usr/local/bin/gem5.opt
COPY --from=builder /src/gem5/build/RISCV /opt/gem5/build/RISCV

CMD ["/bin/bash"]