// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vault is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    struct User {
        address addr;
        uint256 amount;
    }

    User[] public users;
    mapping(address => uint256) public ids;
    IERC20 immutable sampleToken;

    constructor(address _token) {
        sampleToken = IERC20(_token);
    }

    function deposit(uint256 _amount) external nonReentrant {
        uint256 id = ids[_msgSender()];
        if (id == 0) {
            users.push(User(_msgSender(), _amount));
            ids[_msgSender()] = users.length - 1;
        } else {
            users[id].amount += _amount;
        }
        IERC20(sampleToken).safeTransferFrom(_msgSender(), address(this), _amount);
    }

    function withdraw(uint256 _amount) external nonReentrant {
        uint256 id = ids[_msgSender()];
        require(id > 0, "this user doesn't exist");
        require(users[id].amount >= _amount, "withdrawal amount is greater than you've deposited.");
        users[id].amount -= _amount;
        IERC20(sampleToken).safeTransfer(_msgSender(), _amount);
    }

    function findTop2Users() external view returns (address, address) {
        require(users.length > 1, "There is no 2 users yet");

        uint256[2] memory topUserIds;
        topUserIds[0] = 0;
        topUserIds[1] = 1;

        if (users[0].amount < users[1].amount) {
            topUserIds[0] = 1;
            topUserIds[1] = 0;
        }

        if (users.length == 2) {
            return (users[topUserIds[0]].addr, users[topUserIds[1]].addr);
        }

        for (uint256 i = 2; i < users.length; i++) {
            if (users[topUserIds[0]].amount < users[i].amount) {
                topUserIds[1] = topUserIds[0];
                topUserIds[0] = i;
            } else if (users[topUserIds[1]].amount < users[i].amount) {
                topUserIds[1] = i;
            }
        }
        return (users[topUserIds[0]].addr, users[topUserIds[1]].addr);
    }
}
