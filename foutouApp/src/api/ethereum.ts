import axios from "axios";
import { ethers } from "ethers";
import contractABI from "../../../contracts/artifacts/FouTou.json";
import { useEtherStore } from "@/store/ethereum";

const CONTRACT_ADDRESS = "0x13965A9843393d7a4bb2a4b28a83271e6f97BF99";
const etherStore = useEtherStore();

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
	async verifyRole(role: string, account: string): Promise<boolean> {
		const { contract } = initContract();
    const res = await contract.roles(role, account);
    return res; // todo 测试
	},
};
