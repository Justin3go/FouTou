import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import * as path from "path";
// element-plus
import Icons from "unplugin-icons/vite";
import IconsResolver from "unplugin-icons/resolver";
import AutoImport from "unplugin-auto-import/vite";
import Components from "unplugin-vue-components/vite";
import { ElementPlusResolver } from "unplugin-vue-components/resolvers";

const pathSrc = path.resolve(__dirname, "src");

// https://vitejs.dev/config/
export default defineConfig({
	resolve: {
		//设置别名
		alias: {
			"@": pathSrc,
		},
	},
	plugins: [
		vue(),
		AutoImport({
			// Auto import functions from Vue, e.g. ref, reactive, toRef...
			// 自动导入 Vue 相关函数，如：ref, reactive, toRef 等
			imports: ["vue"],
			resolvers: [
				ElementPlusResolver(),
				// Auto import icon components
				// 自动导入图标组件
				IconsResolver({
					prefix: "Icon",
				}),
			],
			dts: path.resolve(pathSrc, "auto-imports.d.ts"),
		}),
		Components({
			resolvers: [
				// Auto register icon components
				// 自动注册图标组件
				IconsResolver({
					enabledCollections: ["ep"],
				}),
				// Auto register Element Plus components
				// 自动导入 Element Plus 组件
				ElementPlusResolver(),
			],

			dts: path.resolve(pathSrc, "components.d.ts"),
		}),

		Icons({
			autoInstall: true,
		}),
	],
});
