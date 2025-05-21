#!/bin/bash

# Install tools specified in mise.toml
#
cd /workspaces/real_time_crypto_trading_bot_with_kubernetes
mise trust
mise install
echo 'eval "$(/usr/local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc
