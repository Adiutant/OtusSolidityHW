// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

/**
 * @title INativeBank
 * @dev Интерфейс для контракта-банка нативной валюты, предоставляющий основные банковские функции.
 */
interface INativeBank {
    /**
     * @dev Генерируется, когда сумма снятия превышает баланс счёта.
     * @param account Адрес аккаунта, который пытался снять средства.
     * @param amount Сумма, которую пытались снять.
     * @param balance Текущий баланс аккаунта.
     */
    error WithdrawalAmountExceedsBalance(address account, uint256 amount, uint256 balance);

    /**
     * @dev Генерируется, когда сумма снятия равна нулю.
     * @param account Адрес аккаунта, который пытался снять средства.
     */
    error WithdrawalZeroAmount(address account);

    /**
     * @dev Генерируется, когда на счёт аккаунта поступает депозит.
     * @param account Адрес аккаунта, на который был сделан депозит.
     * @param amount Сумма, которая была внесена.
     */
    event Deposit(address indexed account, uint256 amount);
    /**
     * @dev Генерируется, когда со счёта снимаются средства.
     * @param account Адрес счёта, с которого произошло снятие.
     * @param amount Сумма, которая была снята.
     */
    event Withdrawal(address indexed account, uint256 amount);

    /**
     * @dev Возвращает баланс счёта.
     * @param account Адрес счёта.
     * @return Баланс счёта.
     */
    function balanceOf(address account) external view returns(uint256);

    /**
     * @dev Вносит средства на счёт.
     */
    function deposit() external payable;
    /**
     * @dev Снимает средства со счёта.
     * @param amount Сумма, которую нужно снять.
     */
    function withdraw(uint256 amount) external;
}

contract Bank is INativeBank {

    mapping (address => uint256) public balanceOf;


    function withdraw(uint256 amount) external override {
        if (amount == 0) {
            revert WithdrawalZeroAmount(msg.sender);
        }
        if (amount > balanceOf[msg.sender]) {
            revert WithdrawalAmountExceedsBalance(msg.sender, amount, balanceOf[msg.sender]);
        }
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Error in deposit");
        unchecked {
            balanceOf[msg.sender] -= amount;
        }
        emit Withdrawal(msg.sender, amount);
    }

    function _deposit(address sender, uint256 value) private {
        balanceOf[sender] += value;
        emit Deposit(sender, value);
    } 
    function deposit() external payable override {
        _deposit(msg.sender, msg.value);
    }

    receive() external payable {  _deposit(msg.sender, msg.value); }

}
