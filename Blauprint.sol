// contracts/Blauprint_collabs.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract Blauprint is ERC721, ERC721Enumerable, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _recortes;
    Counters.Counter private _cuadros;

    string baseURI;
    string public baseExtension = ".json";
    string private _contractURI;
    uint256 public cuadros = 1000;
    
    mapping(address => bool) public isAdmin;

    modifier onlyAdmin() {
        require(isAdmin[msg.sender] || msg.sender == owner());
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        string memory _initialContractURI
    ) ERC721(name, symbol) { 
        _contractURI = _initialContractURI;
    }

    function mintCuadros()
        public onlyAdmin
    {
        require(_cuadros.current() + 1 < cuadros, "El limite de cuadros ha sido alcanzado" );
            _cuadros.increment();
            uint256 mintToken = _cuadros.current();
            _safeMint(msg.sender, mintToken);
            emit Mint(mintToken, msg.sender);
    }

    function mintRecortes()
        public onlyAdmin
    {
            uint256 mintToken = _recortes.current() + 1000;
            _safeMint(msg.sender, mintToken);
            emit Mint(mintToken, msg.sender);
            _recortes.increment();
    }

    function addAdmin(address _add) public onlyAdmin {
        isAdmin[_add] = true;
    }

    function removeAdmin(address _remove) public onlyOwner {
        isAdmin[_remove] = false;
    }

    function TotalMinted() public view returns (uint){
        return _cuadros.current() + _recortes.current();
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function setBaseURI(string memory newBaseUri)
        public
        onlyOwner
        returns (string memory)
    {
        require(
            bytes(newBaseUri).length > 0,
            "Cannot set base address with an invalid 'baseUrl'."
        );

        baseURI = newBaseUri;
        return baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, tokenId.toString(), baseExtension)
                )
                : "";
    }

    function setContractURI(string memory _newContractURI) public onlyOwner {
        _contractURI = _newContractURI;
    }

    function freezeTokenURI(uint256 id) public onlyOwner {
        emit PermanentURI(baseURI, id);
    }

    function freezeTokenURIBatch(uint256[] memory ids) public onlyOwner {
        for (uint256 i; i < ids.length; i++) {
            emit PermanentURI(baseURI, ids[i]);
        }
    }

    /**
     * @dev Emitted when `tokenMetaData` is ready to be frozen
     */
    event PermanentURI(string _value, uint256 indexed _id);

    /**
     * @dev Emitted when a token is minted
     */
    event Mint(uint256 tokenId, address _owner);
    /**
     * Override isApprovedForAll to auto-approve OS's proxy contract
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {
        // if OpenSea's ERC721 Proxy Address is detected, auto-return true
        if (_operator == address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE)) {
            return true;
        }

        // otherwise, use the default ERC721.isApprovedForAll()
        return ERC721.isApprovedForAll(_owner, _operator);
    }

     // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}
