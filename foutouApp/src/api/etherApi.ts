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
	async verifyRole(role: string, account: string): Promise<boolean> {
		const { contract } = initContract();
    const res = await contract.roles(role, account);
    return res; // todo 测试
	},
};
