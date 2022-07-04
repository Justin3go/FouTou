<template>
	<el-dialog
		v-model="dialogVisible"
		title="连接钱包"
		width="30%"
		:before-close="handleClose"
	>
		<img src="/metamask-logo.png" class="wallet-logo" alt="" />
		<span class="wallet-name">MetaMask</span>
		<div class="wallet-msg">连接你的钱包，方便进行后续操作</div>
		<template #footer>
			<span class="dialog-footer">
				<el-button @click="dialogVisible = false">取消</el-button>
				<el-button type="primary" @click="connect">连接</el-button>
			</span>
		</template>
	</el-dialog>
	<el-menu
		:default-active="activeIndex"
		class="el-menu-demo"
		mode="horizontal"
		:ellipsis="false"
		@select="handleSelect"
	>
		<el-menu-item index="0">FouTou</el-menu-item>
		<div class="flex-grow" />
		<el-menu-item index="1">浏览</el-menu-item>
		<el-menu-item index="2">创建</el-menu-item>
		<el-menu-item index="3">主页</el-menu-item>
		<el-sub-menu index="4">
			<template #title>其他</template>
			<el-menu-item index="4-1">排行榜</el-menu-item>
			<el-menu-item index="4-2">连接钱包</el-menu-item>
			<el-menu-item index="4-3">item3</el-menu-item>
		</el-sub-menu>
	</el-menu>
</template>

<script lang="ts" setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { useEtherStore } from "@/store/etherStore";
import { ElMessageBox } from "element-plus";
import "element-plus/es/components/message-box/style/index";
import { ElMessage } from "element-plus";
import "element-plus/es/components/message/style/index";

const etherStore = useEtherStore();
const dialogVisible = ref(false);
const router = useRouter();
const activeIndex = ref("1");
const handleSelect = (key: string, keyPath: string[]) => {
	console.log("navtab: ", key, "|", keyPath);
	if (key === "0") {
		router.push({ path: "/" });
	} else if (key === "1") {
		router.push({ path: "/browse" });
	} else if (key === "2") {
		router.push({ path: "/create" });
	} else if (key === "3") {
		router.push({ path: "/personal" });
	} else if (key === "4" && keyPath[1] === "4-1") {
		console.log("加载排行榜");
	} else if (key === "4-2" && keyPath[1] === "4-2") {
		dialogVisible.value = true;
	} else {
		alert("先莫点，暂时还没想好加些什么");
	}
};
const handleClose = (done: () => void) => {
	ElMessageBox.confirm("是否确认关闭该弹窗", {
		confirmButtonText: "确认",
		cancelButtonText: "取消",
	})
		.then(() => {
			done();
		})
		.catch(() => {
			// catch error
		});
};
const msg1 = () => {
	ElMessage({
		showClose: true,
		message: "你的钱包已经连接",
	});
};
const msg2 = () => {
	ElMessage({
		showClose: true,
		message: "连接成功",
		type: "success",
	});
};
const msg3 = () => {
	ElMessage({
		showClose: true,
		message: "连接失败",
		type: "error",
	});
};
async function connect() {
	if (etherStore.account) {
		msg1();
		dialogVisible.value = false;
		return;
	}
	await etherStore.connectWallet();
	etherStore.account ? msg2() : msg3();
	dialogVisible.value = false;
}
</script>

<style lang="scss" scoped>
.flex-grow {
	flex-grow: 1;
}
.dialog-footer button:first-child {
	margin-right: 10px;
}
.wallet-logo{
	width: 2vw
}
.wallet-name{
	font-size: 2vw
}
.wallet-msg{
	margin: 1vw;
	font-size: 1.3vw;
}
</style>
