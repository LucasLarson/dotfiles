# Changelog

## [Unreleased](https://github.com/LucasLarson/dotfiles/tree/HEAD)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.7.1...HEAD)

**Merged pull requests:**

- bump gunstage from `2b1c779` to `4bcfcda` [\#436](https://github.com/LucasLarson/dotfiles/pull/436) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/fast-syntax-highlighting from `6c072dc` to `84c7e50` [\#435](https://github.com/LucasLarson/dotfiles/pull/435) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/fast-syntax-highlighting from `9a5a4a5` to `6c072dc` [\#434](https://github.com/LucasLarson/dotfiles/pull/434) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/zsh-diff-so-fancy from `9a06bed` to `aadbe4e` [\#433](https://github.com/LucasLarson/dotfiles/pull/433) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `d281e59` to `6520323` [\#431](https://github.com/LucasLarson/dotfiles/pull/431) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `a55955c` to `d281e59` [\#430](https://github.com/LucasLarson/dotfiles/pull/430) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/fast-syntax-highlighting from `817916d` to `9a5a4a5` [\#429](https://github.com/LucasLarson/dotfiles/pull/429) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump powerlevel10k from `ed0bd29` to `a55955c` [\#427](https://github.com/LucasLarson/dotfiles/pull/427) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.7.1](https://github.com/LucasLarson/dotfiles/tree/v0.7.1) (2021-10-30)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.7.0...v0.7.1)

**Merged pull requests:**

- bump Mackup from v0.8.32 to v0.8.33 [\#428](https://github.com/LucasLarson/dotfiles/pull/428) ([renovate[bot]](https://github.com/apps/renovate))
- bump gunstage from `4d6e288` to `2b1c779` [\#425](https://github.com/LucasLarson/dotfiles/pull/425) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump powerlevel10k from `6441a01` to `ed0bd29` [\#424](https://github.com/LucasLarson/dotfiles/pull/424) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump git-default-branch from `2ba4381` to `e219585` [\#423](https://github.com/LucasLarson/dotfiles/pull/423) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump powerlevel10k from `edd9805` to `6441a01` [\#422](https://github.com/LucasLarson/dotfiles/pull/422) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump gunstage from `199b9bc` to `4d6e288` [\#421](https://github.com/LucasLarson/dotfiles/pull/421) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `3e515a7` to `edd9805` [\#420](https://github.com/LucasLarson/dotfiles/pull/420) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump custom/themes/powerlevel10k from `0ce9df6` to `3e515a7` [\#419](https://github.com/LucasLarson/dotfiles/pull/419) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/git-default-branch from `0c7a390` to `2ba4381` [\#418](https://github.com/LucasLarson/dotfiles/pull/418) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/samefile from `8afff8a` to `448cd3c` [\#417](https://github.com/LucasLarson/dotfiles/pull/417) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump powerlevel10k from `7a72acf` to `0ce9df6` [\#416](https://github.com/LucasLarson/dotfiles/pull/416) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.7.0](https://github.com/LucasLarson/dotfiles/tree/v0.7.0) (2021-09-22)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.6.1...v0.7.0)

**Implemented enhancements:**

- add to arrays in a more portable way [\#356](https://github.com/LucasLarson/dotfiles/issues/356)
- find alias to delete merged Git branches [\#275](https://github.com/LucasLarson/dotfiles/issues/275)
- ignore semver minor updates [\#353](https://github.com/LucasLarson/dotfiles/pull/353) ([LucasLarson](https://github.com/LucasLarson))

**Fixed bugs:**

- `find -exec` and `xargs` must 𝑛𝑜𝑡 be followed by `command` [\#392](https://github.com/LucasLarson/dotfiles/issues/392)
- `cd` is a `builtin` not a `command` [\#388](https://github.com/LucasLarson/dotfiles/issues/388)
- replace `builtin cd` with `command cd` for @AlpineLinux \(fix \#388\) [\#393](https://github.com/LucasLarson/dotfiles/pull/393) ([LucasLarson](https://github.com/LucasLarson))
- use `builtin cd` instead of `command cd` \(fix \#388\) [\#391](https://github.com/LucasLarson/dotfiles/pull/391) ([LucasLarson](https://github.com/LucasLarson))
- add reinitialized Mega-Linter installation [\#376](https://github.com/LucasLarson/dotfiles/pull/376) ([LucasLarson](https://github.com/LucasLarson))
- conform to JSON schema; expand, repair comments [\#354](https://github.com/LucasLarson/dotfiles/pull/354) ([LucasLarson](https://github.com/LucasLarson))

**Closed issues:**

- consider 𝑥 \>/dev/null 2\>&1 instead of printf 𝑥 [\#315](https://github.com/LucasLarson/dotfiles/issues/315)
- include crufty `.zcompdump` files in `cleanup` [\#199](https://github.com/LucasLarson/dotfiles/issues/199)

**Merged pull requests:**

- bump zsh-completions from `3273291` to `bebaa61` [\#415](https://github.com/LucasLarson/dotfiles/pull/415) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump powerlevel10k from `c5c9178` to `7a72acf` [\#414](https://github.com/LucasLarson/dotfiles/pull/414) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump zchee-zsh-completions from `303e682` to `8de9211` [\#413](https://github.com/LucasLarson/dotfiles/pull/413) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `b3b0efb` to `c5c9178` [\#411](https://github.com/LucasLarson/dotfiles/pull/411) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump custom/plugins/zchee-zsh-completions from `229cf48` to `303e682` [\#410](https://github.com/LucasLarson/dotfiles/pull/410) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump custom/plugins/zsh-completions from `f52061c` to `3273291` [\#409](https://github.com/LucasLarson/dotfiles/pull/409) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump custom/themes/powerlevel10k from `e362b69` to `b3b0efb` [\#408](https://github.com/LucasLarson/dotfiles/pull/408) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump custom/plugins/zsh-completions from `394239d` to `f52061c` [\#406](https://github.com/LucasLarson/dotfiles/pull/406) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump custom/themes/powerlevel10k from `379b97e` to `e362b69` [\#405](https://github.com/LucasLarson/dotfiles/pull/405) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `32e76e7` to `379b97e` [\#404](https://github.com/LucasLarson/dotfiles/pull/404) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/zsh-completions from `d4511c2` to `394239d` [\#402](https://github.com/LucasLarson/dotfiles/pull/402) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/zchee-zsh-completions from `690cc73` to `229cf48` [\#401](https://github.com/LucasLarson/dotfiles/pull/401) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump custom/themes/powerlevel10k from `8f798f9` to `32e76e7` [\#400](https://github.com/LucasLarson/dotfiles/pull/400) ([dependabot[bot]](https://github.com/apps/dependabot))
- replace `find -exec command` with `find -exec` \(fix \#392\) [\#398](https://github.com/LucasLarson/dotfiles/pull/398) ([LucasLarson](https://github.com/LucasLarson))
- Bump custom/themes/powerlevel10k from `83d80fa` to `e3c8529` [\#395](https://github.com/LucasLarson/dotfiles/pull/395) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/zsh-completions from `a736cfe` to `d4511c2` [\#394](https://github.com/LucasLarson/dotfiles/pull/394) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `1e7be00` to `83d80fa` [\#390](https://github.com/LucasLarson/dotfiles/pull/390) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `4bcc519` to `1e7be00` [\#389](https://github.com/LucasLarson/dotfiles/pull/389) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `f4668bc` to `4bcc519` [\#387](https://github.com/LucasLarson/dotfiles/pull/387) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `fd7313a` to `f4668bc` [\#386](https://github.com/LucasLarson/dotfiles/pull/386) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `0c862a1` to `fd7313a` [\#385](https://github.com/LucasLarson/dotfiles/pull/385) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump custom/plugins/zsh-completions from `9dfd5c6` to `a736cfe` [\#384](https://github.com/LucasLarson/dotfiles/pull/384) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump custom/themes/powerlevel10k from `c003c25` to `0c862a1` [\#383](https://github.com/LucasLarson/dotfiles/pull/383) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `67f494c` to `c003c25` [\#382](https://github.com/LucasLarson/dotfiles/pull/382) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `717573d` to `67f494c` [\#381](https://github.com/LucasLarson/dotfiles/pull/381) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `f5d6184` to `717573d` [\#380](https://github.com/LucasLarson/dotfiles/pull/380) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `4ba3c01` to `f5d6184` [\#379](https://github.com/LucasLarson/dotfiles/pull/379) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `b9c62ca` to `4ba3c01` [\#378](https://github.com/LucasLarson/dotfiles/pull/378) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `f217e4a` to `b9c62ca` [\#377](https://github.com/LucasLarson/dotfiles/pull/377) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `35acee1` to `f217e4a` [\#375](https://github.com/LucasLarson/dotfiles/pull/375) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/gunstage from `b44728b` to `199b9bc` [\#374](https://github.com/LucasLarson/dotfiles/pull/374) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/git-default-branch from `c465f20` to `0c7a390` [\#373](https://github.com/LucasLarson/dotfiles/pull/373) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/samefile from `66e8257` to `8afff8a` [\#372](https://github.com/LucasLarson/dotfiles/pull/372) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `c597206` to `35acee1` [\#371](https://github.com/LucasLarson/dotfiles/pull/371) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/git-default-branch from `9a249f3` to `c465f20` [\#369](https://github.com/LucasLarson/dotfiles/pull/369) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `a3494a5` to `c597206` [\#368](https://github.com/LucasLarson/dotfiles/pull/368) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update github/super-linter action to v4 [\#367](https://github.com/LucasLarson/dotfiles/pull/367) ([renovate[bot]](https://github.com/apps/renovate))
- Bump custom/themes/powerlevel10k from `9c03410` to `a3494a5` [\#366](https://github.com/LucasLarson/dotfiles/pull/366) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `f924646` to `9c03410` [\#365](https://github.com/LucasLarson/dotfiles/pull/365) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/fast-syntax-highlighting from `a62d721` to `817916d` [\#364](https://github.com/LucasLarson/dotfiles/pull/364) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/gunstage from `a420181` to `b44728b` [\#363](https://github.com/LucasLarson/dotfiles/pull/363) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/Shell Script.tmbundle from `37404fb` to `5b6cee0` [\#362](https://github.com/LucasLarson/dotfiles/pull/362) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `8d1daa4` to `f924646` [\#361](https://github.com/LucasLarson/dotfiles/pull/361) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/CTags.tmbundle from `17c7f03` to `f29558b` [\#360](https://github.com/LucasLarson/dotfiles/pull/360) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/gunstage from `2c6e99e` to `a420181` [\#359](https://github.com/LucasLarson/dotfiles/pull/359) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update peter-evans/create-pull-request action to v3.9.2 [\#355](https://github.com/LucasLarson/dotfiles/pull/355) ([renovate[bot]](https://github.com/apps/renovate))

## [v0.6.1](https://github.com/LucasLarson/dotfiles/tree/v0.6.1) (2021-05-06)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.6.0...v0.6.1)

**Closed issues:**

- `actions/setup-ruby` is deprecated [\#344](https://github.com/LucasLarson/dotfiles/issues/344)
- perform a `grep -inrP password` [\#299](https://github.com/LucasLarson/dotfiles/issues/299)

**Merged pull requests:**

- repair readme [\#352](https://github.com/LucasLarson/dotfiles/pull/352) ([LucasLarson](https://github.com/LucasLarson))
- ignore semver minor updates [\#351](https://github.com/LucasLarson/dotfiles/pull/351) ([LucasLarson](https://github.com/LucasLarson))
- Bump custom/plugins/zsh-completions from `11ad0a4` to `9dfd5c6` [\#350](https://github.com/LucasLarson/dotfiles/pull/350) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update stefanzweifel/git-auto-commit-action action to v4.11.0 [\#349](https://github.com/LucasLarson/dotfiles/pull/349) ([renovate[bot]](https://github.com/apps/renovate))
- Bump custom/plugins/gunstage from `ad882d6` to `2c6e99e` [\#348](https://github.com/LucasLarson/dotfiles/pull/348) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/zsh-completions from `e14d470` to `11ad0a4` [\#347](https://github.com/LucasLarson/dotfiles/pull/347) ([dependabot[bot]](https://github.com/apps/dependabot))
- replace deprecated `actions/setup-ruby` with `ruby/setup-ruby` \(fix \#344\) [\#345](https://github.com/LucasLarson/dotfiles/pull/345) ([LucasLarson](https://github.com/LucasLarson))
- Update github/super-linter action to v3.16.3 [\#343](https://github.com/LucasLarson/dotfiles/pull/343) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.33.0 [\#341](https://github.com/LucasLarson/dotfiles/pull/341) ([renovate[bot]](https://github.com/apps/renovate))
- Bump custom/plugins/zsh-completions from `773ead6` to `e14d470` [\#340](https://github.com/LucasLarson/dotfiles/pull/340) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/Shell Script.tmbundle from `f9ffa6a` to `37404fb` [\#339](https://github.com/LucasLarson/dotfiles/pull/339) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/gunstage from `d170bd6` to `ad882d6` [\#338](https://github.com/LucasLarson/dotfiles/pull/338) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update github/super-linter action to v3.16.1 [\#337](https://github.com/LucasLarson/dotfiles/pull/337) ([renovate[bot]](https://github.com/apps/renovate))
- Bump custom/plugins/zsh-completions from `252c7a9` to `773ead6` [\#336](https://github.com/LucasLarson/dotfiles/pull/336) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/Swift.tmbundle from `2ee3d7c` to `8c7672d` [\#335](https://github.com/LucasLarson/dotfiles/pull/335) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update ibiqlik/action-yamllint action to v3.0.1 [\#334](https://github.com/LucasLarson/dotfiles/pull/334) ([renovate[bot]](https://github.com/apps/renovate))
- Bump custom/plugins/zsh-completions from `d7959bb` to `252c7a9` [\#333](https://github.com/LucasLarson/dotfiles/pull/333) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump nvuillam/mega-linter from v4.31.0 to v4.32.0 [\#332](https://github.com/LucasLarson/dotfiles/pull/332) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/zsh-completions from `901a787` to `d7959bb` [\#331](https://github.com/LucasLarson/dotfiles/pull/331) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `48ff2e8` to `8d1daa4` [\#330](https://github.com/LucasLarson/dotfiles/pull/330) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update nvuillam/mega-linter action to v4.32.0 [\#329](https://github.com/LucasLarson/dotfiles/pull/329) ([renovate[bot]](https://github.com/apps/renovate))
- Bump custom/plugins/zsh-completions from `cb4b721` to `901a787` [\#328](https://github.com/LucasLarson/dotfiles/pull/328) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `b55ad16` to `48ff2e8` [\#327](https://github.com/LucasLarson/dotfiles/pull/327) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/gunstage from `134f5c5` to `d170bd6` [\#326](https://github.com/LucasLarson/dotfiles/pull/326) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/zsh-completions from `43fecdf` to `cb4b721` [\#325](https://github.com/LucasLarson/dotfiles/pull/325) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `30bd946` to `b55ad16` [\#324](https://github.com/LucasLarson/dotfiles/pull/324) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update stefanzweifel/git-auto-commit-action action to v4.10.0 [\#323](https://github.com/LucasLarson/dotfiles/pull/323) ([renovate[bot]](https://github.com/apps/renovate))
- Update actions/cache action to v2.1.5 [\#322](https://github.com/LucasLarson/dotfiles/pull/322) ([renovate[bot]](https://github.com/apps/renovate))
- Bump custom/themes/powerlevel10k from `8dc9100` to `30bd946` [\#321](https://github.com/LucasLarson/dotfiles/pull/321) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/zsh-completions from `f0c8569` to `43fecdf` [\#320](https://github.com/LucasLarson/dotfiles/pull/320) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update actions/upload-artifact action to v2.2.3 [\#318](https://github.com/LucasLarson/dotfiles/pull/318) ([renovate[bot]](https://github.com/apps/renovate))
- Bump nvuillam/mega-linter from v4.30.0 to v4.31.0 [\#317](https://github.com/LucasLarson/dotfiles/pull/317) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `4d15cf9` to `8dc9100` [\#316](https://github.com/LucasLarson/dotfiles/pull/316) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `af86b53` to `4d15cf9` [\#313](https://github.com/LucasLarson/dotfiles/pull/313) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `58f5470` to `af86b53` [\#312](https://github.com/LucasLarson/dotfiles/pull/312) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/zsh-completions from `788926f` to `f0c8569` [\#311](https://github.com/LucasLarson/dotfiles/pull/311) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/zsh-completions from `f1ab611` to `788926f` [\#310](https://github.com/LucasLarson/dotfiles/pull/310) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/gunstage from `da7ec97` to `134f5c5` [\#309](https://github.com/LucasLarson/dotfiles/pull/309) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update github/super-linter action to v3.15.5 [\#308](https://github.com/LucasLarson/dotfiles/pull/308) ([renovate[bot]](https://github.com/apps/renovate))
- Bump custom/themes/powerlevel10k from `7d786b9` to `58f5470` [\#307](https://github.com/LucasLarson/dotfiles/pull/307) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `d28e84c` to `7d786b9` [\#306](https://github.com/LucasLarson/dotfiles/pull/306) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/zsh-completions from `aa98bc5` to `f1ab611` [\#304](https://github.com/LucasLarson/dotfiles/pull/304) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/Bundle Support.tmbundle from `90d74c8` to `f2fbd0f` [\#303](https://github.com/LucasLarson/dotfiles/pull/303) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/Ruby.tmbundle from `02613b0` to `efcb894` [\#302](https://github.com/LucasLarson/dotfiles/pull/302) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update fkirc/skip-duplicate-actions action to v3.4.0 [\#301](https://github.com/LucasLarson/dotfiles/pull/301) ([renovate[bot]](https://github.com/apps/renovate))
- Update UnicornGlobal/has-changes-action action to v1.0.12 [\#300](https://github.com/LucasLarson/dotfiles/pull/300) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.30.0 [\#298](https://github.com/LucasLarson/dotfiles/pull/298) ([renovate[bot]](https://github.com/apps/renovate))
- Bump custom/plugins/gunstage from `23350c6` to `da7ec97` [\#297](https://github.com/LucasLarson/dotfiles/pull/297) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update nvuillam/mega-linter action to v4.29.0 [\#296](https://github.com/LucasLarson/dotfiles/pull/296) ([renovate[bot]](https://github.com/apps/renovate))
- Bump github/super-linter from v3.15.2 to v3.15.3 [\#295](https://github.com/LucasLarson/dotfiles/pull/295) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/plugins/gunstage from `ac7ee86` to `23350c6` [\#292](https://github.com/LucasLarson/dotfiles/pull/292) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `6d545d5` to `d28e84c` [\#291](https://github.com/LucasLarson/dotfiles/pull/291) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/Bundle Support.tmbundle from `13169c6` to `90d74c8` [\#290](https://github.com/LucasLarson/dotfiles/pull/290) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump custom/themes/powerlevel10k from `3920940` to `6d545d5` [\#289](https://github.com/LucasLarson/dotfiles/pull/289) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update nvuillam/mega-linter action to v4.28.0 [\#255](https://github.com/LucasLarson/dotfiles/pull/255) ([renovate[bot]](https://github.com/apps/renovate))

## [v0.6.0](https://github.com/LucasLarson/dotfiles/tree/v0.6.0) (2021-03-07)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.5.4...v0.6.0)

**Implemented enhancements:**

- enable `sudo` even for aliases [\#273](https://github.com/LucasLarson/dotfiles/issues/273)
- remove `motd` generally [\#262](https://github.com/LucasLarson/dotfiles/issues/262)
- pip installation can be slow: let the user know [\#261](https://github.com/LucasLarson/dotfiles/issues/261)

**Fixed bugs:**

- restore @Dependabot file location to reactivate service [\#269](https://github.com/LucasLarson/dotfiles/pull/269) ([LucasLarson](https://github.com/LucasLarson))

**Closed issues:**

- is `PATH` `coreutils` constructed safely? [\#208](https://github.com/LucasLarson/dotfiles/issues/208)

**Merged pull requests:**

- Update github/super-linter action to v3.15.2 [\#288](https://github.com/LucasLarson/dotfiles/pull/288) ([renovate[bot]](https://github.com/apps/renovate))
- Update stefanzweifel/git-auto-commit-action action to v4.9.2 [\#287](https://github.com/LucasLarson/dotfiles/pull/287) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/gunstage from `69f8b2e` to `ac7ee86` [\#286](https://github.com/LucasLarson/dotfiles/pull/286) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/zsh-completions from `322d5f2` to `aa98bc5` [\#284](https://github.com/LucasLarson/dotfiles/pull/284) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update github/super-linter action to v3.15.1 [\#283](https://github.com/LucasLarson/dotfiles/pull/283) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/zsh-completions from `c7baec4` to `322d5f2` [\#282](https://github.com/LucasLarson/dotfiles/pull/282) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update stefanzweifel/git-auto-commit-action action to v4.9.1 [\#281](https://github.com/LucasLarson/dotfiles/pull/281) ([renovate[bot]](https://github.com/apps/renovate))
- add `.gitignore` for @nvuillam’s Mega-Linter [\#280](https://github.com/LucasLarson/dotfiles/pull/280) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `b816abf` to `3920940` [\#279](https://github.com/LucasLarson/dotfiles/pull/279) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/HTML.tmbundle from `0c3d5ee` to `56a5f29` [\#278](https://github.com/LucasLarson/dotfiles/pull/278) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update stefanzweifel/git-auto-commit-action action to v4.9.0 [\#277](https://github.com/LucasLarson/dotfiles/pull/277) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/gunstage from `ae301df` to `69f8b2e` [\#272](https://github.com/LucasLarson/dotfiles/pull/272) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/zsh-completions from `6fe9995` to `c7baec4` [\#271](https://github.com/LucasLarson/dotfiles/pull/271) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/Swift.tmbundle from `d31bae2` to `2ee3d7c` [\#270](https://github.com/LucasLarson/dotfiles/pull/270) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update peter-evans/create-pull-request action to v3.8.2 [\#268](https://github.com/LucasLarson/dotfiles/pull/268) ([renovate[bot]](https://github.com/apps/renovate))
- add notice that installing pip is slow \(fix \#261\) [\#267](https://github.com/LucasLarson/dotfiles/pull/267) ([LucasLarson](https://github.com/LucasLarson))
- Update actions/setup-ruby action to v1.1.3 [\#266](https://github.com/LucasLarson/dotfiles/pull/266) ([renovate[bot]](https://github.com/apps/renovate))
- if there’s `/etc/motd`, clear its contents without newline \(fix \#262\) [\#265](https://github.com/LucasLarson/dotfiles/pull/265) ([LucasLarson](https://github.com/LucasLarson))
- Update peter-evans/create-pull-request action to v3.8.1 [\#263](https://github.com/LucasLarson/dotfiles/pull/263) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/zsh-completions from `b8cc3b9` to `6fe9995` [\#258](https://github.com/LucasLarson/dotfiles/pull/258) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/gunstage from `d47af9f` to `ae301df` [\#257](https://github.com/LucasLarson/dotfiles/pull/257) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update actions/cache action to v2.1.4 [\#254](https://github.com/LucasLarson/dotfiles/pull/254) ([renovate[bot]](https://github.com/apps/renovate))
- repair jsonlint workflow’s `find` syntax [\#253](https://github.com/LucasLarson/dotfiles/pull/253) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/plugins/gunstage from `c39ed05` to `d47af9f` [\#252](https://github.com/LucasLarson/dotfiles/pull/252) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update peter-evans/create-pull-request action to v3.8.0 [\#250](https://github.com/LucasLarson/dotfiles/pull/250) ([renovate[bot]](https://github.com/apps/renovate))
- Update github/super-linter action to v3.14.5 [\#249](https://github.com/LucasLarson/dotfiles/pull/249) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.26.1 [\#248](https://github.com/LucasLarson/dotfiles/pull/248) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `d26bdcd` to `b816abf` [\#246](https://github.com/LucasLarson/dotfiles/pull/246) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/gunstage from `2735a15` to `f6eb870` [\#245](https://github.com/LucasLarson/dotfiles/pull/245) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update peter-evans/create-pull-request action to v3.7.0 [\#243](https://github.com/LucasLarson/dotfiles/pull/243) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.26.0 [\#242](https://github.com/LucasLarson/dotfiles/pull/242) ([renovate[bot]](https://github.com/apps/renovate))

## [v0.5.4](https://github.com/LucasLarson/dotfiles/tree/v0.5.4) (2021-01-24)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.5.3...v0.5.4)

**Closed issues:**

- Action Required: Fix Renovate Configuration [\#240](https://github.com/LucasLarson/dotfiles/issues/240)

**Merged pull requests:**

- Update nvuillam/mega-linter action to v4.25.0 [\#241](https://github.com/LucasLarson/dotfiles/pull/241) ([renovate[bot]](https://github.com/apps/renovate))
- \[autofix\] Format JSON content [\#239](https://github.com/LucasLarson/dotfiles/pull/239) ([github-actions[bot]](https://github.com/apps/github-actions))
- Update nvuillam/mega-linter action to v4.24.1 [\#237](https://github.com/LucasLarson/dotfiles/pull/237) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/gunstage from `9b12374` to `2735a15` [\#236](https://github.com/LucasLarson/dotfiles/pull/236) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `7b0698d` to `d26bdcd` [\#235](https://github.com/LucasLarson/dotfiles/pull/235) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/zsh-completions from `244cbfc` to `00c7e28` [\#234](https://github.com/LucasLarson/dotfiles/pull/234) ([dependabot[bot]](https://github.com/apps/dependabot))
- \[autofix\] Format JSON content [\#233](https://github.com/LucasLarson/dotfiles/pull/233) ([github-actions[bot]](https://github.com/apps/github-actions))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `68abcc8` to `7b0698d` [\#232](https://github.com/LucasLarson/dotfiles/pull/232) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update nvuillam/mega-linter action to v4.24.0 [\#231](https://github.com/LucasLarson/dotfiles/pull/231) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.23.3 [\#230](https://github.com/LucasLarson/dotfiles/pull/230) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `00232d1` to `68abcc8` [\#229](https://github.com/LucasLarson/dotfiles/pull/229) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/gunstage from `2ad6e04` to `9b12374` [\#228](https://github.com/LucasLarson/dotfiles/pull/228) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update nvuillam/mega-linter action to v4.23.1 [\#227](https://github.com/LucasLarson/dotfiles/pull/227) ([renovate[bot]](https://github.com/apps/renovate))
- Bump nvuillam/mega-linter from v4.22.1 to v4.23.0 [\#226](https://github.com/LucasLarson/dotfiles/pull/226) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump github/super-linter from v3.14.3 to v3.14.4 [\#225](https://github.com/LucasLarson/dotfiles/pull/225) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update nvuillam/mega-linter action to v4.23.0 [\#224](https://github.com/LucasLarson/dotfiles/pull/224) ([renovate[bot]](https://github.com/apps/renovate))
- Update github/super-linter action to v3.14.4 [\#223](https://github.com/LucasLarson/dotfiles/pull/223) ([renovate[bot]](https://github.com/apps/renovate))
- Bump Library/Application Support/TextMate/Managed/Bundles/Python.tmbundle from `1c579ef` to `02dbf8b` [\#222](https://github.com/LucasLarson/dotfiles/pull/222) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update nvuillam/mega-linter action to v4.22.1 [\#221](https://github.com/LucasLarson/dotfiles/pull/221) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.22.0 [\#220](https://github.com/LucasLarson/dotfiles/pull/220) ([renovate[bot]](https://github.com/apps/renovate))
- \[autofix\] Typo [\#219](https://github.com/LucasLarson/dotfiles/pull/219) ([github-actions[bot]](https://github.com/apps/github-actions))
- \[autofix\] Format JSON content [\#217](https://github.com/LucasLarson/dotfiles/pull/217) ([github-actions[bot]](https://github.com/apps/github-actions))
- add scaffolding for `~/.zlogin` [\#216](https://github.com/LucasLarson/dotfiles/pull/216) ([LucasLarson](https://github.com/LucasLarson))
- Bump actions/upload-artifact from v2.2.1 to v2.2.2 [\#215](https://github.com/LucasLarson/dotfiles/pull/215) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update actions/upload-artifact action to v2.2.2 [\#214](https://github.com/LucasLarson/dotfiles/pull/214) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.21.0 [\#213](https://github.com/LucasLarson/dotfiles/pull/213) ([renovate[bot]](https://github.com/apps/renovate))
- Update dependency mackup to v0.8.32 [\#212](https://github.com/LucasLarson/dotfiles/pull/212) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/zsh-completions from `9def41a` to `244cbfc` [\#211](https://github.com/LucasLarson/dotfiles/pull/211) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update dependency mackup to v0.8.31 [\#210](https://github.com/LucasLarson/dotfiles/pull/210) ([renovate[bot]](https://github.com/apps/renovate))
- Update dependency mackup to v0.8.30 [\#209](https://github.com/LucasLarson/dotfiles/pull/209) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/zsh-completions from `44c5bce` to `9def41a` [\#207](https://github.com/LucasLarson/dotfiles/pull/207) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update nvuillam/mega-linter action to v4.20.0 [\#205](https://github.com/LucasLarson/dotfiles/pull/205) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/zsh-completions from `2e009c7` to `44c5bce` [\#204](https://github.com/LucasLarson/dotfiles/pull/204) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update nvuillam/mega-linter action to v4.19.0 [\#203](https://github.com/LucasLarson/dotfiles/pull/203) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/zsh-syntax-highlighting from `1715f39` to `5eb4948` [\#202](https://github.com/LucasLarson/dotfiles/pull/202) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `e8afa80` to `d524164` [\#201](https://github.com/LucasLarson/dotfiles/pull/201) ([dependabot[bot]](https://github.com/apps/dependabot))
- reactivate @Dependabot [\#200](https://github.com/LucasLarson/dotfiles/pull/200) ([LucasLarson](https://github.com/LucasLarson))
- Update peter-evans/create-pull-request action to v3.6.0 [\#198](https://github.com/LucasLarson/dotfiles/pull/198) ([renovate[bot]](https://github.com/apps/renovate))

## [v0.5.3](https://github.com/LucasLarson/dotfiles/tree/v0.5.3) (2020-12-23)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.5.2...v0.5.3)

**Implemented enhancements:**

- remove archival material from the version-control system [\#187](https://github.com/LucasLarson/dotfiles/issues/187)
- `${SHELL##*/}` depends on user configuration; `${0##*[-/]}` does not [\#186](https://github.com/LucasLarson/dotfiles/issues/186)

**Fixed bugs:**

- hardcoded references to `edit` will break [\#177](https://github.com/LucasLarson/dotfiles/issues/177)
- regression: `find -size 0` doesn’t find all empty directories [\#170](https://github.com/LucasLarson/dotfiles/issues/170)

**Merged pull requests:**

- Update nvuillam/mega-linter action to v4.18.0 [\#197](https://github.com/LucasLarson/dotfiles/pull/197) ([renovate[bot]](https://github.com/apps/renovate))
- Update fkirc/skip-duplicate-actions action to v3.3.0 [\#196](https://github.com/LucasLarson/dotfiles/pull/196) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.17.0 [\#195](https://github.com/LucasLarson/dotfiles/pull/195) ([renovate[bot]](https://github.com/apps/renovate))
- Update fkirc/skip-duplicate-actions action to v3.2.0 [\#194](https://github.com/LucasLarson/dotfiles/pull/194) ([renovate[bot]](https://github.com/apps/renovate))
- remove archival and example content \(fix \#187\) [\#193](https://github.com/LucasLarson/dotfiles/pull/193) ([LucasLarson](https://github.com/LucasLarson))
- Update fkirc/skip-duplicate-actions action to v3.1.0 [\#192](https://github.com/LucasLarson/dotfiles/pull/192) ([renovate[bot]](https://github.com/apps/renovate))
- Update stefanzweifel/git-auto-commit-action action to v4.8.0 [\#191](https://github.com/LucasLarson/dotfiles/pull/191) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.16.0 [\#188](https://github.com/LucasLarson/dotfiles/pull/188) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.15.0 [\#185](https://github.com/LucasLarson/dotfiles/pull/185) ([renovate[bot]](https://github.com/apps/renovate))
- Update fkirc/skip-duplicate-actions action to v3 [\#184](https://github.com/LucasLarson/dotfiles/pull/184) ([renovate[bot]](https://github.com/apps/renovate))
- Update peter-evans/create-pull-request action to v3.5.2 [\#183](https://github.com/LucasLarson/dotfiles/pull/183) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.14.2 [\#182](https://github.com/LucasLarson/dotfiles/pull/182) ([renovate[bot]](https://github.com/apps/renovate))
- add @meyerweb’s `please` function [\#181](https://github.com/LucasLarson/dotfiles/pull/181) ([LucasLarson](https://github.com/LucasLarson))
- Update fkirc/skip-duplicate-actions action to v2.2.0 [\#180](https://github.com/LucasLarson/dotfiles/pull/180) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.14.1 [\#179](https://github.com/LucasLarson/dotfiles/pull/179) ([renovate[bot]](https://github.com/apps/renovate))
- Update nvuillam/mega-linter action to v4.14.0 [\#178](https://github.com/LucasLarson/dotfiles/pull/178) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/gunstage from `57f545b` to `2ad6e04` [\#176](https://github.com/LucasLarson/dotfiles/pull/176) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `2c3bcd8` to `b90b362` [\#174](https://github.com/LucasLarson/dotfiles/pull/174) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update nvuillam/mega-linter action to v4.13.0 [\#173](https://github.com/LucasLarson/dotfiles/pull/173) ([renovate[bot]](https://github.com/apps/renovate))
- Update github/super-linter action to v3.14.3 [\#172](https://github.com/LucasLarson/dotfiles/pull/172) ([renovate[bot]](https://github.com/apps/renovate))
- repair Markdown after Mega-Linter suggestions [\#171](https://github.com/LucasLarson/dotfiles/pull/171) ([LucasLarson](https://github.com/LucasLarson))
- Update github/super-linter action to v3.14.0 [\#169](https://github.com/LucasLarson/dotfiles/pull/169) ([renovate[bot]](https://github.com/apps/renovate))
- mega-linter conformance [\#168](https://github.com/LucasLarson/dotfiles/pull/168) ([LucasLarson](https://github.com/LucasLarson))
- add mega-linter workflow action [\#167](https://github.com/LucasLarson/dotfiles/pull/167) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `31ede3c` to `2c3bcd8` [\#166](https://github.com/LucasLarson/dotfiles/pull/166) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/Swift.tmbundle from `97d29d2` to `d31bae2` [\#165](https://github.com/LucasLarson/dotfiles/pull/165) ([dependabot[bot]](https://github.com/apps/dependabot))
- repair Dependabot [\#164](https://github.com/LucasLarson/dotfiles/pull/164) ([LucasLarson](https://github.com/LucasLarson))
- Alpine Linux 2nd attempt resurrection [\#163](https://github.com/LucasLarson/dotfiles/pull/163) ([LucasLarson](https://github.com/LucasLarson))
- add out-of-the-box `.bashrc` file from new Ubuntu installation [\#162](https://github.com/LucasLarson/dotfiles/pull/162) ([LucasLarson](https://github.com/LucasLarson))
- add initialization script for Alpine Linux [\#161](https://github.com/LucasLarson/dotfiles/pull/161) ([LucasLarson](https://github.com/LucasLarson))

## [v0.5.2](https://github.com/LucasLarson/dotfiles/tree/v0.5.2) (2020-11-25)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.5.1...v0.5.2)

**Merged pull requests:**

- Update peter-evans/create-pull-request action to v3.5.1 [\#160](https://github.com/LucasLarson/dotfiles/pull/160) ([renovate[bot]](https://github.com/apps/renovate))

## [v0.5.1](https://github.com/LucasLarson/dotfiles/tree/v0.5.1) (2020-11-23)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.5.0...v0.5.1)

**Merged pull requests:**

- add `git status` to `git push` alias [\#159](https://github.com/LucasLarson/dotfiles/pull/159) ([LucasLarson](https://github.com/LucasLarson))
- allow `git verify-commit`’s alias to allow a commit hash as argument [\#158](https://github.com/LucasLarson/dotfiles/pull/158) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `04f75a1` to `31ede3c` [\#157](https://github.com/LucasLarson/dotfiles/pull/157) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `7969eb3` to `04f75a1` [\#156](https://github.com/LucasLarson/dotfiles/pull/156) ([dependabot[bot]](https://github.com/apps/dependabot))
- test replacing LucasLarson with `${{ github.repository_owner }}` in TOML file [\#155](https://github.com/LucasLarson/dotfiles/pull/155) ([LucasLarson](https://github.com/LucasLarson))
- replace toml repository name programmatically [\#154](https://github.com/LucasLarson/dotfiles/pull/154) ([LucasLarson](https://github.com/LucasLarson))
- Bump peter-evans/create-pull-request from v3.4.1 to v3.5.0 [\#153](https://github.com/LucasLarson/dotfiles/pull/153) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update peter-evans/create-pull-request action to v3.5.0 [\#152](https://github.com/LucasLarson/dotfiles/pull/152) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `09be56b` to `7969eb3` [\#151](https://github.com/LucasLarson/dotfiles/pull/151) ([dependabot[bot]](https://github.com/apps/dependabot))
- \[autofix\] Format JSON content [\#150](https://github.com/LucasLarson/dotfiles/pull/150) ([github-actions[bot]](https://github.com/apps/github-actions))
- repair spacing in identifying device operating system [\#149](https://github.com/LucasLarson/dotfiles/pull/149) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `feaf120` to `09be56b` [\#148](https://github.com/LucasLarson/dotfiles/pull/148) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/gunstage from `aa2d2c7` to `57f545b` [\#147](https://github.com/LucasLarson/dotfiles/pull/147) ([dependabot[bot]](https://github.com/apps/dependabot))
- replace @gaurav-nelson and @ad-m nothing for link-status validation [\#145](https://github.com/LucasLarson/dotfiles/pull/145) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `e2db860` to `feaf120` [\#144](https://github.com/LucasLarson/dotfiles/pull/144) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `f6c24d2` to `e2db860` [\#143](https://github.com/LucasLarson/dotfiles/pull/143) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/gunstage from `ec14424` to `aa2d2c7` [\#142](https://github.com/LucasLarson/dotfiles/pull/142) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `2fc7257` to `f6c24d2` [\#141](https://github.com/LucasLarson/dotfiles/pull/141) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update ibiqlik/action-yamllint action to v3 [\#139](https://github.com/LucasLarson/dotfiles/pull/139) ([renovate[bot]](https://github.com/apps/renovate))
- remove duplicate image-optimizing action [\#138](https://github.com/LucasLarson/dotfiles/pull/138) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/plugins/gunstage from `c62f44b` to `ec14424` [\#137](https://github.com/LucasLarson/dotfiles/pull/137) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `d7861fc` to `2fc7257` [\#136](https://github.com/LucasLarson/dotfiles/pull/136) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/gunstage from `4c8e591` to `c62f44b` [\#135](https://github.com/LucasLarson/dotfiles/pull/135) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update actions/cache action to v2.1.3 [\#134](https://github.com/LucasLarson/dotfiles/pull/134) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/gunstage from `d7963dc` to `4c8e591` [\#133](https://github.com/LucasLarson/dotfiles/pull/133) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update github/super-linter action to v3.13.5 [\#130](https://github.com/LucasLarson/dotfiles/pull/130) ([renovate[bot]](https://github.com/apps/renovate))
- Update actions/checkout action to v2.3.4 [\#129](https://github.com/LucasLarson/dotfiles/pull/129) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/gunstage from `b183bde` to `d7963dc` [\#128](https://github.com/LucasLarson/dotfiles/pull/128) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/zsh-syntax-highlighting from `2ebfa6a` to `1715f39` [\#127](https://github.com/LucasLarson/dotfiles/pull/127) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update github/super-linter action to v3.13.3 [\#126](https://github.com/LucasLarson/dotfiles/pull/126) ([renovate[bot]](https://github.com/apps/renovate))
- make `wget` work on Alpine Linux and macOS [\#124](https://github.com/LucasLarson/dotfiles/pull/124) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/plugins/gunstage from `e27fce3` to `b6ba688` [\#123](https://github.com/LucasLarson/dotfiles/pull/123) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `5e2422d` to `d7861fc` [\#122](https://github.com/LucasLarson/dotfiles/pull/122) ([dependabot[bot]](https://github.com/apps/dependabot))
- \[autofix\] Format JSON content [\#121](https://github.com/LucasLarson/dotfiles/pull/121) ([github-actions[bot]](https://github.com/apps/github-actions))
- Bump .oh-my-zsh/custom/plugins/gunstage from `3f287df` to `e27fce3` [\#120](https://github.com/LucasLarson/dotfiles/pull/120) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `aa6d40b` to `5e2422d` [\#118](https://github.com/LucasLarson/dotfiles/pull/118) ([dependabot[bot]](https://github.com/apps/dependabot))
- move commented CodeQL analysis into autofix multifarious workflow [\#117](https://github.com/LucasLarson/dotfiles/pull/117) ([LucasLarson](https://github.com/LucasLarson))
- repair changelog generator [\#116](https://github.com/LucasLarson/dotfiles/pull/116) ([LucasLarson](https://github.com/LucasLarson))
- Bump gaurav-nelson/github-action-markdown-link-check from 1.0.7 to 1.0.8 [\#115](https://github.com/LucasLarson/dotfiles/pull/115) ([dependabot[bot]](https://github.com/apps/dependabot))
- repair workflow’s YAML formatting [\#114](https://github.com/LucasLarson/dotfiles/pull/114) ([LucasLarson](https://github.com/LucasLarson))
- revert to 1.0.7 gaurav-nelson/github-action-markdown-link-check from 1.0.8 [\#113](https://github.com/LucasLarson/dotfiles/pull/113) ([LucasLarson](https://github.com/LucasLarson))
- add Contributor Covenant Code of Conduct for Pedants [\#112](https://github.com/LucasLarson/dotfiles/pull/112) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `2ea3356` to `aa6d40b` [\#111](https://github.com/LucasLarson/dotfiles/pull/111) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `74c6e18` to `2ea3356` [\#110](https://github.com/LucasLarson/dotfiles/pull/110) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `49d5617` to `74c6e18` [\#109](https://github.com/LucasLarson/dotfiles/pull/109) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `68c89ec` to `49d5617` [\#108](https://github.com/LucasLarson/dotfiles/pull/108) ([dependabot[bot]](https://github.com/apps/dependabot))
- \[autofix\] Format JSON content [\#107](https://github.com/LucasLarson/dotfiles/pull/107) ([github-actions[bot]](https://github.com/apps/github-actions))
- \[autofix\] Format JSON content [\#106](https://github.com/LucasLarson/dotfiles/pull/106) ([github-actions[bot]](https://github.com/apps/github-actions))

## [v0.5.0](https://github.com/LucasLarson/dotfiles/tree/v0.5.0) (2020-10-25)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.4.3...v0.5.0)

**Fixed bugs:**

- stackoverrun.com appears down [\#79](https://github.com/LucasLarson/dotfiles/issues/79)

**Merged pull requests:**

- Bump .oh-my-zsh/custom/plugins/gunstage from `a02fabd` to `3f287df` [\#105](https://github.com/LucasLarson/dotfiles/pull/105) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `de0e022` to `68c89ec` [\#104](https://github.com/LucasLarson/dotfiles/pull/104) ([dependabot[bot]](https://github.com/apps/dependabot))
- replace tabs with two spaces for `editorconfig-checker` compliance [\#103](https://github.com/LucasLarson/dotfiles/pull/103) ([LucasLarson](https://github.com/LucasLarson))
- Update github/super-linter action to v3.13.2 [\#102](https://github.com/LucasLarson/dotfiles/pull/102) ([renovate[bot]](https://github.com/apps/renovate))
- Update gaurav-nelson/github-action-markdown-link-check action to v1.0.8 [\#99](https://github.com/LucasLarson/dotfiles/pull/99) ([renovate[bot]](https://github.com/apps/renovate))
- Bump .oh-my-zsh/custom/plugins/gunstage from `394fa6b` to `54d2ea3` [\#98](https://github.com/LucasLarson/dotfiles/pull/98) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump github/super-linter from v3.13.0 to v3.13.1 [\#97](https://github.com/LucasLarson/dotfiles/pull/97) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/gunstage from `5f87b6a` to `394fa6b` [\#96](https://github.com/LucasLarson/dotfiles/pull/96) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump github/super-linter from v3.12.0 to v3.13.0 [\#95](https://github.com/LucasLarson/dotfiles/pull/95) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/zsh-syntax-highlighting from `62c5575` to `2ebfa6a` [\#94](https://github.com/LucasLarson/dotfiles/pull/94) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump peter-evans/create-pull-request from v3.4.0 to v3.4.1 [\#93](https://github.com/LucasLarson/dotfiles/pull/93) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/gunstage from `24eb142` to `5f87b6a` [\#92](https://github.com/LucasLarson/dotfiles/pull/92) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `9b981b8` to `b770e6a` [\#91](https://github.com/LucasLarson/dotfiles/pull/91) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/gunstage from `6b68ebd` to `24eb142` [\#90](https://github.com/LucasLarson/dotfiles/pull/90) ([dependabot[bot]](https://github.com/apps/dependabot))
- Pin dependency mackup to ==0.8.29 [\#89](https://github.com/LucasLarson/dotfiles/pull/89) ([renovate[bot]](https://github.com/apps/renovate))
- Configure Renovate [\#88](https://github.com/LucasLarson/dotfiles/pull/88) ([renovate[bot]](https://github.com/apps/renovate))
- bump @GitHub Super-Linter from v3.11.0 to v3.12.0 [\#86](https://github.com/LucasLarson/dotfiles/pull/86) ([LucasLarson](https://github.com/LucasLarson))
- call `jsonlint-newline-fork` instead of `jsonlint` [\#85](https://github.com/LucasLarson/dotfiles/pull/85) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `060af91` to `9b981b8` [\#83](https://github.com/LucasLarson/dotfiles/pull/83) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.4.3](https://github.com/LucasLarson/dotfiles/tree/v0.4.3) (2020-10-05)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.4.2...v0.4.3)

**Fixed bugs:**

- stackoverrun.com appears down [\#80](https://github.com/LucasLarson/dotfiles/issues/80)

**Merged pull requests:**

- replace `jsonlint` with `jsonlint-newline-fork` [\#82](https://github.com/LucasLarson/dotfiles/pull/82) ([LucasLarson](https://github.com/LucasLarson))
- restore newline in JSON autofix [\#77](https://github.com/LucasLarson/dotfiles/pull/77) ([LucasLarson](https://github.com/LucasLarson))
- \[autofix\] Format JSON content [\#76](https://github.com/LucasLarson/dotfiles/pull/76) ([github-actions[bot]](https://github.com/apps/github-actions))
- repair autofix for JSON [\#75](https://github.com/LucasLarson/dotfiles/pull/75) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/plugins/gunstage from `ecffcba` to `6b68ebd` [\#73](https://github.com/LucasLarson/dotfiles/pull/73) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.4.2](https://github.com/LucasLarson/dotfiles/tree/v0.4.2) (2020-10-03)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.4.1...v0.4.2)

**Implemented enhancements:**

- add Rust Cargo bin to $PATH only if it exists \(fix \#68\) [\#71](https://github.com/LucasLarson/dotfiles/pull/71) ([LucasLarson](https://github.com/LucasLarson))

**Closed issues:**

- verify `~/.cargo/bin` exists before adding to `$PATH` [\#68](https://github.com/LucasLarson/dotfiles/issues/68)

**Merged pull requests:**

- Bump .oh-my-zsh/custom/themes/powerlevel10k from `42aa719` to `060af91` [\#72](https://github.com/LucasLarson/dotfiles/pull/72) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/gunstage from `b14876e` to `ecffcba` [\#70](https://github.com/LucasLarson/dotfiles/pull/70) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `71b39f0` to `42aa719` [\#69](https://github.com/LucasLarson/dotfiles/pull/69) ([dependabot[bot]](https://github.com/apps/dependabot))
- add Android SDK to $PATH only if it exists [\#66](https://github.com/LucasLarson/dotfiles/pull/66) ([LucasLarson](https://github.com/LucasLarson))
- copyedit boilerplate text [\#65](https://github.com/LucasLarson/dotfiles/pull/65) ([LucasLarson](https://github.com/LucasLarson))
- Bump .oh-my-zsh/custom/plugins/gunstage from `0897849` to `b14876e` [\#64](https://github.com/LucasLarson/dotfiles/pull/64) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update actions/checkout requirement to v2.3.3 [\#62](https://github.com/LucasLarson/dotfiles/pull/62) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump gaurav-nelson/github-action-markdown-link-check from v1.0.7 to 1.0.7 [\#61](https://github.com/LucasLarson/dotfiles/pull/61) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/Python.tmbundle from `cbf5109` to `1c579ef` [\#60](https://github.com/LucasLarson/dotfiles/pull/60) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.4.1](https://github.com/LucasLarson/dotfiles/tree/v0.4.1) (2020-09-23)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.4.0...v0.4.1)

**Merged pull requests:**

- Bump .oh-my-zsh/custom/plugins/gunstage from `945a464` to `0897849` [\#59](https://github.com/LucasLarson/dotfiles/pull/59) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `3b77282` to `71b39f0` [\#58](https://github.com/LucasLarson/dotfiles/pull/58) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `f14b58e` to `3b77282` [\#57](https://github.com/LucasLarson/dotfiles/pull/57) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/plugins/gunstage from `cf9f502` to `945a464` [\#56](https://github.com/LucasLarson/dotfiles/pull/56) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `afb854d` to `f14b58e` [\#55](https://github.com/LucasLarson/dotfiles/pull/55) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `12cef82` to `afb854d` [\#54](https://github.com/LucasLarson/dotfiles/pull/54) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `6221309` to `12cef82` [\#52](https://github.com/LucasLarson/dotfiles/pull/52) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump Library/Application Support/TextMate/Managed/Bundles/C.tmbundle from `60daf83` to `cc68c3b` [\#50](https://github.com/LucasLarson/dotfiles/pull/50) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `6c8c6ee` to `6221309` [\#49](https://github.com/LucasLarson/dotfiles/pull/49) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `3b2f474` to `6c8c6ee` [\#48](https://github.com/LucasLarson/dotfiles/pull/48) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `a3727dc` to `3b2f474` [\#47](https://github.com/LucasLarson/dotfiles/pull/47) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `c1db392` to `a3727dc` [\#45](https://github.com/LucasLarson/dotfiles/pull/45) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `f2bf019` to `c1db392` [\#44](https://github.com/LucasLarson/dotfiles/pull/44) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `7eb501c` to `f2bf019` [\#43](https://github.com/LucasLarson/dotfiles/pull/43) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.4.0](https://github.com/LucasLarson/dotfiles/tree/v0.4.0) (2020-08-26)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.3.0...v0.4.0)

**Implemented enhancements:**

- add @GitHub standard issue templates [\#41](https://github.com/LucasLarson/dotfiles/pull/41) ([LucasLarson](https://github.com/LucasLarson))
- add, remove @GitHub’s CodeQL [\#22](https://github.com/LucasLarson/dotfiles/pull/22) ([LucasLarson](https://github.com/LucasLarson))
- add @GitHub Super-Linter [\#20](https://github.com/LucasLarson/dotfiles/pull/20) ([LucasLarson](https://github.com/LucasLarson))

**Merged pull requests:**

- bump .oh-my-zsh/custom/themes/powerlevel10k from `6279aa5` to `7eb501c` [\#42](https://github.com/LucasLarson/dotfiles/pull/42) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `dca8774` to `6279aa5` [\#40](https://github.com/LucasLarson/dotfiles/pull/40) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `7114902` to `dca8774` [\#38](https://github.com/LucasLarson/dotfiles/pull/38) ([dependabot[bot]](https://github.com/apps/dependabot))
- add Markdown link checker action [\#37](https://github.com/LucasLarson/dotfiles/pull/37) ([LucasLarson](https://github.com/LucasLarson))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `525e254` to `7114902` [\#36](https://github.com/LucasLarson/dotfiles/pull/36) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `c425a5e` to `525e254` [\#35](https://github.com/LucasLarson/dotfiles/pull/35) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `03ab8e9` to `c425a5e` [\#34](https://github.com/LucasLarson/dotfiles/pull/34) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `ebfaae2` to `03ab8e9` [\#33](https://github.com/LucasLarson/dotfiles/pull/33) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `7a0bf99` to `ebfaae2` [\#32](https://github.com/LucasLarson/dotfiles/pull/32) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `c48b81e` to `7a0bf99` [\#31](https://github.com/LucasLarson/dotfiles/pull/31) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `03e6187` to `c48b81e` [\#30](https://github.com/LucasLarson/dotfiles/pull/30) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `422b7a9` to `03e6187` [\#29](https://github.com/LucasLarson/dotfiles/pull/29) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `05ff662` to `422b7a9` [\#28](https://github.com/LucasLarson/dotfiles/pull/28) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `2ba87f4` to `05ff662` [\#27](https://github.com/LucasLarson/dotfiles/pull/27) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `88d5fb6` to `2ba87f4` [\#25](https://github.com/LucasLarson/dotfiles/pull/25) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `7a114ad` to `88d5fb6` [\#24](https://github.com/LucasLarson/dotfiles/pull/24) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `620e69f` to `7a114ad` [\#23](https://github.com/LucasLarson/dotfiles/pull/23) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump .oh-my-zsh/custom/themes/powerlevel10k from `4635fca` to `620e69f` [\#21](https://github.com/LucasLarson/dotfiles/pull/21) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.3.0](https://github.com/LucasLarson/dotfiles/tree/v0.3.0) (2020-07-15)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.2.0...v0.3.0)

**Closed issues:**

- WS-2019-0379 \(Medium\) detected in commons-codec-1.10.jar [\#15](https://github.com/LucasLarson/dotfiles/issues/15)

**Merged pull requests:**

- Bump .oh-my-zsh/custom/themes/powerlevel10k from `a28d450` to `4635fca` [\#19](https://github.com/LucasLarson/dotfiles/pull/19) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `0c341b6` to `a28d450` [\#18](https://github.com/LucasLarson/dotfiles/pull/18) ([dependabot[bot]](https://github.com/apps/dependabot))
- \[ImgBot\] Optimize images [\#17](https://github.com/LucasLarson/dotfiles/pull/17) ([imgbot[bot]](https://github.com/apps/imgbot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `e0ed693` to `0c341b6` [\#16](https://github.com/LucasLarson/dotfiles/pull/16) ([dependabot[bot]](https://github.com/apps/dependabot))
- Configure WhiteSource Bolt for GitHub [\#14](https://github.com/LucasLarson/dotfiles/pull/14) ([whitesource-bolt-for-github[bot]](https://github.com/apps/whitesource-bolt-for-github))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `be66f21` to `e0ed693` [\#13](https://github.com/LucasLarson/dotfiles/pull/13) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `a88e11f` to `be66f21` [\#12](https://github.com/LucasLarson/dotfiles/pull/12) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `ae32fd5` to `a88e11f` [\#11](https://github.com/LucasLarson/dotfiles/pull/11) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `1be10eb` to `ae32fd5` [\#10](https://github.com/LucasLarson/dotfiles/pull/10) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `8854cb6` to `1be10eb` [\#9](https://github.com/LucasLarson/dotfiles/pull/9) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `eda706c` to `8854cb6` [\#7](https://github.com/LucasLarson/dotfiles/pull/7) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `5e5d3f5` to `eda706c` [\#6](https://github.com/LucasLarson/dotfiles/pull/6) ([dependabot[bot]](https://github.com/apps/dependabot))
- bump powerlevel10k submodule to `5e5d3f5` from `3e17260` [\#5](https://github.com/LucasLarson/dotfiles/pull/5) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump mackup from 0.8.28 to 0.8.29 [\#4](https://github.com/LucasLarson/dotfiles/pull/4) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump .oh-my-zsh/custom/themes/powerlevel10k from `c009153` to `3e17260` [\#3](https://github.com/LucasLarson/dotfiles/pull/3) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.2.0](https://github.com/LucasLarson/dotfiles/tree/v0.2.0) (2020-05-22)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/v0.1.0...v0.2.0)

## [v0.1.0](https://github.com/LucasLarson/dotfiles/tree/v0.1.0) (2020-05-19)

[Full Changelog](https://github.com/LucasLarson/dotfiles/compare/4b904db476a5c712c5064e508415e663d7d5dff8...v0.1.0)

**Merged pull requests:**

- zsh enable command auto-correction [\#2](https://github.com/LucasLarson/dotfiles/pull/2) ([LucasLarson](https://github.com/LucasLarson))
- .gitconfig: add compression options [\#1](https://github.com/LucasLarson/dotfiles/pull/1) ([LucasLarson](https://github.com/LucasLarson))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
