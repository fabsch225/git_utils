## Git Utilities

### Merge-Mono
- merge multiple and possibly nested repos into one mono-repo

#### Usage

```shell
chmod +x merge_mono.sh
```

```shell
./mrege_mono.sh /path/to/monorepo /path/to/repos
```

### Commit-All
- Commit everything in multiple and possibly nested repos
- Maximum depth is can be passed as a parameter (default=1)

#### Usage
```shell
chmod +x commit_all.sh
```

```shell
./commit_all.sh "Your commit message" /path/to/your/repos [1]
```