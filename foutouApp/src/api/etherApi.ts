import axios from "axios";
import { ethers } from "ethers";
import contractABI from "../../../contracts/artifacts/FouTou.json";
// import { useEtherStore } from "@/store/etherStore"; 非vue组件不能使用pinia

const CONTRACT_ADDRESS = "0x9720d61428dCCDD8E12C545CB3510f746411D7Cb";
// debugger
// const etherStore = useEtherStore();

function initContract() {
	const { ethereum } = window;
	if (ethereum) {
		const provider = new ethers.providers.Web3Provider(ethereum);
		const signer = provider.getSigner();
		const contract = new ethers.Contract(
			CONTRACT_ADDRESS,
			contractABI.abi,
			signer
		);
		return { provider, signer, contract };
	} else {
		throw "Ethereum object doesn't exist!";
	}
}

export const Auth = {
	/**
	 * 验证某个账户是否属于某个角色(SUPER_ADMIN, ADMIN, USER)
	 * @param role bytes32 哈希了的role字符，以下三选一
	 * SUPER_ADMIN=>0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
	 * ADMIN=>0xd980155b32cf66e6af51e0972d64b9d5efe0e6f237dfaa4bdc83f990dd79e9c8
	 * USER=>0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96
	 * @param account address
	 */
	verifyRole(role: string, account: string): Promise<boolean> {
		const { contract } = initContract();
		return contract.roles(role, account);
	},

	getADMIN_NUM(): Promise<number> {
		const { contract } = initContract();
		return contract.ADMIN_NUM();
	},
	getREQUIRED_ADMIN(): Promise<number> {
		const { contract } = initContract();
		return contract.REQUIRED_ADMIN();
	},
	getREQUIRED_REPOERTER(): Promise<number> {
		const { contract } = initContract();
		return contract.REQUIRED_REPOERTER();
	},
	getREQUIRED_FANS(): Promise<number> {
		const { contract } = initContract();
		return contract.REQUIRED_FANS();
	},
	getIS_TEST_VERSION(): Promise<boolean> {
		const { contract } = initContract();
		return contract.IS_TEST_VERSION();
	},
	// setConfig(){},
	// transferSUPER_ADMIN(){},
	/**
	 * @param account address
	 */
	USER2ADMIN(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.USER2ADMIN(account);
	},
	/**
	 * @param account address
	 */
	ADMIN2USER(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.ADMIN2USER(account);
	},
	/**
	 * @param account address
	 */
	registerByAdmin(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.registerByAdmin(account);
	},
	/**
	 * @param account address
	 */
	publicRegister(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.publicRegister(account);
	},
};
