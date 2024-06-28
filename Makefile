-include .env

.PHONY: all update install build clean clean-git clean-coverage-report clean-lcov clean-slither clean-aderyn test test-ext test-ext2 coverage coverage-lcov slither aderyn scopefile scope script-deploy-live script-deploy-dry sudo-act

all: clean install build

### Core

update :; forge update

install :; foundryup && forge install foundry-rs/forge-std --no-commit && forge install vectorized/solady --no-commit && forge install OpenZeppelin/openzeppelin-contracts --no-commit

build :; forge build

### Clean

clean: clean-git clean-coverage-report clean-lcov clean-slither clean-aderyn

clean-git :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules

clean-coverage-report :; -rm -rf coverage-report

clean-lcov :; -rm -rf lcov.info

clean-slither :; -rm -rf slither.txt

clean-aderyn :; -rm -rf aderyn-report.md

### Testing & Coverage

test :; forge test
test-ext: test coverage-lcov slither aderyn
test-ext2: test coverage-lcov slitherin aderyn

coverage :; forge coverage

coverage-lcov :; forge coverage --report lcov && genhtml -o report --branch-coverage lcov.info && mv report coverage-report

slither :; -slither . --config-file slither.config.json --exclude-dependencies > slither.txt 2>&1

slitherin :; -slitherin . --config-file slither.config.json --exclude-dependencies > slither.txt 2>&1

aderyn :; aderyn . && mv report.md aderyn-report.md

### Scope

scopefile :; @tree ./src/ | sed 's/└/#/g' | awk -F '── ' '!/\.sol$$/ { path[int((length($$0) - length($$2))/2)] = $$2; next } { p = "src"; for(i=2; i<=int((length($$0) - length($$2))/2); i++) if (path[i] != "") p = p "/" path[i]; print p "/" $$2; }' > scope.txt

scope :; tree ./src/ | sed 's/└/#/g; s/──/--/g; s/├/#/g; s/│ /|/g; s/│/|/g'

### Deploy

# TODO
