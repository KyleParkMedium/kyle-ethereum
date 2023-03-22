// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract Owner {
    /*
     *  Events
     */
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);

    /*
     *  views
     */
    uint public constant MAX_OWNER_COUNT = 50;

    /*
     *  Storage
     */
    mapping(address => bool) public isOwner;
    address public admin;
    address[] public owners;
    uint public required;

    /*
     *  Constructor
     */
    constructor() {
        admin = msg.sender;
    }

    /*
     *  Modifiers
     */
    modifier isAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0));
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        require(
            ownerCount <= MAX_OWNER_COUNT &&
                _required <= ownerCount &&
                _required != 0 &&
                ownerCount != 0
        );
        _;
    }

    /*
     *  Fallback & Receive
     */
    /// @dev Fallback function allows to deposit ether.
    fallback() external payable {
        if (msg.value > 0) emit Deposit(msg.sender, msg.value);
    }

    receive() external payable {}

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(
        address owner
    )
        public
        onlyWallet
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    /// @dev Allows to add new owners. Transaction has to be sent by wallet.
    /// @param _owners Address of new owners.
    function addOwners(address[] memory _owners) public onlyWallet {
        for (uint i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0));
            //     validRequirement(owners.length + 1, required)
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
            emit OwnerAddition(_owners[i]);
        }
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner) public onlyWallet ownerExists(owner) {
        isOwner[owner] = false;

        for (uint i = 0; i < isOwner.length; i++) {}
        // 확인해야함
        if (required > owners.length) changeRequirement(owners.length);

        for (uint i = 0; i < owners.length; i++)
            if (owners[i] == owner) {
                delete owners[i];
                break;
            }

        emit OwnerRemoval(owner);
    }

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner to be replaced.
    /// @param newOwner Address of new owner.
    function replaceOwner(
        address owner,
        address newOwner
    ) public onlyWallet ownerExists(owner) ownerDoesNotExist(newOwner) {
        for (uint i = 0; i < owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    /// @dev Allows to add required.
    /// @param _required Number of required.
    function addRequired(uint _required) public isAdmin {
        changeRequirement(_required);
    }

    /// @dev Allows to sub required.
    /// @param _required Number of required.
    function subRequired(uint _required) public isAdmin {
        changeRequirement(required - _required);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(
        uint _required
    ) public onlyWallet validRequirement(owners.length, _required) {
        required = _required;
        emit RequirementChange(_required);
    }
}
