// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BookRental.sol";

contract DeployBookRental is Script {
    function run() external {
        // -------------------------
        // Start broadcasting using whatever private key is passed via CLI
        // -------------------------
        vm.startBroadcast();

        // -------------------------
        // Deploy the BookRental contract
        // -------------------------
        BookRental bookRental = new BookRental();

        // -------------------------
        // Log the deployed contract address
        // -------------------------
        console2.log("BookRental deployed at:", address(bookRental));

        vm.stopBroadcast();
    }
}
