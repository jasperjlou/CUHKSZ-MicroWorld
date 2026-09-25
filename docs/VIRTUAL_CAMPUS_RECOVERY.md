# 旧虚拟校园恢复记录

核查日期：2026-09-25。结论：**PARTIALLY_RECOVERABLE**（文件级恢复已证实；完整 Unity 工程运行、材质一致性和再分发许可未验证）。不能将主分支页面空白解读为模型已丢失。

## 已完成的恢复

- **VERIFIED**：完整 clone（非 shallow），188 个可达提交；五个远端分支：`main`、`model_combine`、`PUN-tut`、`character_merge`、`mp_dev`。
- **VERIFIED**：`main` 为 `15251ed4568c24ed640f74fce807811f360e987d`，树内只有模式 `160000` 的 `virtual-campus-v2`，指向 `7e1fc5d2e40f80848c214a652406cba283e74801`。主树及可达历史未找到 `.gitmodules`，没有可以直接初始化的 URL 映射。该指针的 commit 对象却就在本仓库对象库，可 `git ls-tree` 读取。
- **VERIFIED**：`model_combine` 为 `87e2d897fb2264a6b659407522a525f28f7cf211`，144 文件，123 个模型/材质/贴图候选；包含真实二进制 `.blend`，不是仅有指针。`PUN-tut` / `character_merge` 同指 `70af5806fd834f65c40e4eb201bcce17d5ea879d`，各 27,498 文件；`mp_dev` 为 `adb4310244fd40066b43f5d21af85810e4543b16`，8,885 文件。
- **VERIFIED**：已将行政楼、图书馆、树木集合三个样本恢复到忽略目录 `.tools/research/recovered_reference/`，检查 `BLENDER` 文件头及 SHA-256。没有加载附带脚本，也没有向正式资产目录复制。
- **VERIFIED**：历史还保存 `latest.blend` / `latest_modified*.blend`。提交 `0a1e8c73` 将建筑、树拆开；当前找不到旧文件名不代表无法恢复。
- **VERIFIED**：`git lfs ls-files --all -l` 找到 `model_combined/tree&Flower.blend`；`git lfs fetch --all` 下载成功，102,218,192 字节，SHA-256 为 `cd6c1616626f56991f44ebf8864bc5bdb0b23731e3fbdea494caa90d827cb077`，与 LFS OID 一致。另一个无 `&` 的 `treeAndFlower.blend` 是普通 Git blob，不能混为一个文件。

| 恢复样本 | 字节 | SHA-256 |
|---|---:|---|
| administrationV3.blend | 1,880,680 | 15fb8eb571888785cc4c8e019f11e2252e18527a79df9d159be505d18e1d3100 |
| libaray_v2.blend | 3,671,328 | cebaacd50ccc0b3274c87e9f307a89a44ce3ce96f79cf443b920ac4a476b8f50 |
| model_combined/treeAndFlower.blend | 103,786,652 | 0f097848cdeca1516bfc42a7538c6160327b397f6219b90770ad3d5fa8ce74d7 |

## 模型覆盖

**VERIFIED（文件存在，不保证内容质量）**：诚道、道远、乐天、知新、TA、TBCD/RA、行政楼、新图书馆、逸夫 ABC/DEF、学勤、上园、教工宿舍、会议中心、公交站、道路设施及整合建筑；体育馆有 ZIP。志仁的重建文件在历史中。学生活动中心、南门、地形是否完整应打开集合进一步辨认，目前 **UNVERIFIED**。

[Issue #4](https://github.com/newbie-at-cuhksz/virtual-campus-v2/issues/4) 是分工清单，不是完整交付清单；其中未勾选的道远、逸夫楼也能找到文件。[Issue #6](https://github.com/newbie-at-cuhksz/virtual-campus-v2/issues/6) 指明整合分支；[Issue #11](https://github.com/newbie-at-cuhksz/virtual-campus-v2/issues/11) 记录材质烘焙问题，故不能假设直接导出即可得到正确颜色。附件含第三方收费工具线索，未下载或使用该工具。

## 其他恢复渠道

**VERIFIED**：GitHub API 返回 0 tags、0 releases、0 PR，12 issues，已读取 issue comments。四个 fork 已核查默认树：

| fork | 默认树情况 |
|---|---|
| webDrag0n/virtual-campus-v2 | 同 main 指针 |
| AARONkjLee/virtual-campus-v2 | `b5228528`，19 项，含 TA/T-bcd 等 Blender 文件 |
| linzhonghao3/virtual-campus-v2 | `5ddc8e29`，10 项，保留早期 DAE 导出 |
| ZhiQing-R/virtual-campus-v2 | 同 `5ddc8e29` |

**NOT_FOUND（限定此次查询）**：Wayback CDX 对该仓库 URL 前缀的 200 快照查询返回 `[]`，不证明全网不存在备份。无需依赖 Wayback 即可恢复上述 Git 对象。

**CONTACTABLE**：仓库贡献者公开账号包括 OkamiWong、Timothy-197、IceShip423、ZhiQing-R、linzhonghao3；论文通讯作者蔡玮的公开学术邮箱 `caiwei@cuhk.edu.cn`。仅整理联系渠道，未发送邮件或 issue。优先请求：建筑模型权属确认、研究演示及再分发许可、第三方树木/人物剥离清单、最终整合版本。

## 可复现命令

```powershell
git clone https://github.com/newbie-at-cuhksz/virtual-campus-v2.git .tools/research/virtual-campus-v2
git -C .tools/research/virtual-campus-v2 branch -a
git -C .tools/research/virtual-campus-v2 ls-tree -rl origin/model_combine
git -C .tools/research/virtual-campus-v2 ls-tree -rl 7e1fc5d2e40f80848c214a652406cba283e74801
git -C .tools/research/virtual-campus-v2 log --all --name-only -- '*.blend' '*.fbx' '*.dae'
git -C .tools/research/virtual-campus-v2 lfs fetch --all
```

二进制恢复用 Python `subprocess.check_output` 写 bytes，避免旧 PowerShell 的文本重定向破坏文件。完整检索收据在本地 `.tools/research/`；可提交的精简资产索引在 `asset_catalog.json`。本次 **LICENSE_UNCLEAR**，恢复成功不等于可导入游戏。
