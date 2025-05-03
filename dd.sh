#!/bin/bash
# ===============================================
# 🧰 VPS 系统重装助手（交互菜单版）
# ✍️ 作者：Joey
# 🌐 博客：https://joeyblog.net
# 💬 Telegram 群：https://t.me/+ft-zI76oovgwNmRh
# 📌 基于项目：https://github.com/bin456789/reinstall
# ===============================================

# 彩色输出函数
green()  { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
red()    { echo -e "\033[31m$1\033[0m"; }

# 欢迎信息
clear
green "╔══════════════════════════════════════════╗"
green "║         VPS 系统重装交互工具            ║"
green "╠══════════════════════════════════════════╣"
yellow "✍️ 作者：Joey"
yellow "🌐 博客：https://joeyblog.net"
yellow "💬 Telegram 群：https://t.me/+ft-zI76oovgwNmRh"
green "--------------------------------------------"

# 获取最新 reinstall.sh
TMP_FILE="/tmp/reinstall.sh"
curl -fsSL https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh -o "$TMP_FILE" || {
    red "❌ 无法下载 reinstall.sh 脚本，请检查网络。"
    exit 1
}

# 提取系统列表（仅 Linux 发行版）
mapfile -t lines < <(grep -E '^\s{23}[a-z]+' "$TMP_FILE" | grep -vE 'windows|dd|netboot|--img|--iso|--minimal')

declare -A systems
i=1
for line in "${lines[@]}"; do
    name=$(echo "$line" | awk '{print $1}')
    versions=$(echo "$line" | sed "s/.*$name\s*//")
    if [[ -n "$versions" ]]; then
        systems[$i]="$name|$versions"
        printf "  %2d. %s\n" "$i" "$name"
        ((i++))
    fi
done

echo
read -rp "👉 请输入系统编号: " sys_choice

selected="${systems[$sys_choice]}"
if [[ -z "$selected" ]]; then
    red "❌ 无效选择，脚本退出。"
    exit 1
fi

sys_name="${selected%%|*}"
versions="${selected#*|}"

# 显示版本菜单
IFS='|' read -ra ver_arr <<< "$versions"
echo
green "------ 请选择 $sys_name 的版本 ------"
for i in "${!ver_arr[@]}"; do
    printf "  %2d. %s\n" "$((i+1))" "${ver_arr[i]}"
done

echo
read -rp "👉 请输入版本编号: " ver_choice
version="${ver_arr[$((ver_choice-1))]}"

if [[ -z "$version" ]]; then
    red "❌ 无效版本选择，脚本退出。"
    exit 1
fi

# 构造命令
echo
green "🚀 即将执行命令："
yellow "bash reinstall.sh $sys_name $version"
echo
read -rp "是否继续执行？[Y/n]: " confirm
if [[ "$confirm" =~ ^[Yy]?$ ]]; then
    bash <(curl -fsSL https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh) "$sys_name" "$version"
else
    green "✅ 已取消执行。"
fi
