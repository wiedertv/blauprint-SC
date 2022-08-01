// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract blauprint1155 is ERC1155, AccessControl, Ownable, ERC1155Burnable, ERC1155Supply, ERC2981 {
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    uint256 public collabQuantityLimit;
    uint256 public collabTokenLimit;
    using Strings for uint256;
    string public contractURI;
    string public _uri;
    string public name;
    string public symbol;

     constructor(string memory initialContractURI, 
     string memory _name, 
     string memory _symbol, 
     string memory uri_, 
     uint96 _royaltyFeesInBips, 
     uint256 _collabQuantityLimit, 
     uint256 _collabTokenLimit 
     )
        ERC1155(_uri)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MODERATOR_ROLE, msg.sender);
        setRoyaltyInfo(msg.sender, _royaltyFeesInBips);
        _uri = uri_; 
        symbol= _symbol;
        name= _name;
        collabQuantityLimit = _collabQuantityLimit;
        collabTokenLimit = _collabTokenLimit;
        contractURI = initialContractURI;
    }

    function setURI(string memory newuri) public onlyRole(MODERATOR_ROLE) {
        _uri= newuri;
        _setURI(newuri);
    }

    function create(uint256 amount, uint256 _tokenId) public onlyRole(MODERATOR_ROLE)
    {
        require(totalSupply(_tokenId) + amount <= collabQuantityLimit, "No se pueden crear mas");
        require( _tokenId > 0 , "El token no puede ser 0");
        require( _tokenId <= collabTokenLimit, "Este numero de token no esta permitido");
        _mint(msg.sender, _tokenId, amount, '');
    }

    function setContractURI(string memory newContractURI) public onlyRole(MODERATOR_ROLE) {
        contractURI = newContractURI;
    }

    function airdrop( uint256 _quantity, address _to, uint256 _token) public onlyRole(MODERATOR_ROLE) {
        require(totalSupply(_token) + _quantity <= collabQuantityLimit, "No se pueden crear mas");
        require( _token > 0 , "El token no puede ser 0");
        require( _token <= collabTokenLimit, "Este numero de token no esta permitido");
            _mint(_to, _token, _quantity, "");
    }
    
    function batchAirdrop( uint256[] memory _quantity, address[] memory _to, uint256 _token) public onlyRole(MODERATOR_ROLE) {
        require( _quantity.length == _to.length, 'Quantity array must have exact lenght than _to array');
        require( _token > 0 , "El token no puede ser 0");
        require( _token <= collabTokenLimit, "Este numero de token no esta permitido");
        for (uint256 i = 0; i < _quantity.length ; i++){
            uint256 amount = _quantity[i];
            require(totalSupply(_token) + amount <= collabQuantityLimit, "No se pueden crear mas");
            _mint(_to[i], _token, _quantity[i], "");
        }
    }

    function setRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips) public onlyRole(MODERATOR_ROLE) {
        _setDefaultRoyalty(_receiver, _royaltyFeesInBips);
    }

    function setTokenRoyalty(uint256 tokenId , address receiver, uint96 feeNumerato) public onlyRole(MODERATOR_ROLE){
        _setTokenRoyalty(tokenId, receiver, feeNumerato);
    }

    function resetTokenRoyalty(uint256 tokenId)public onlyRole(MODERATOR_ROLE) {
        _resetTokenRoyalty(tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function uri(uint256 tokenId) public view override returns (string memory)  
    {
        return bytes(_uri).length > 0 ? string(abi.encodePacked(_uri, tokenId.toString(), ".json")) : "";
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
