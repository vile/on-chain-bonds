# Test Folder Structure

## ./deploy-gas/SimpleDeployTest.t.sol

Contains two functions that are used to compare the gas prices of proxy vs raw contract deployment.

## ./mocks

Contain mock contracts used during tests (e.g., mock ERC20 token(s)).

## ./unit

Contains normal unit test contracts to verify protocol functionality.

## ./TestBase.sol 

Basic test base contract that contains two variations of `setUp()`, as both a virtual `setUp` function and as a modifier.
Both completely deploy the protocol (implementation, beacon, and proxy factory), and have commonly reused variables and imports.
