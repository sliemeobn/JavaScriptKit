// NOTICE: This is auto-generated code by BridgeJS from JavaScriptKit,
// DO NOT EDIT.
//
// To update this file, just rebuild your project or run
// `swift package bridge-js`.

export interface TypeScriptProcessor {
    convert(ts: string): string;
    validate(ts: string): boolean;
    readonly version: string;
}
export interface CodeGenerator {
    generate(input: any): string;
    readonly outputFormat: string;
}
export type Exports = {
}
export type Imports = {
    createTS2Skeleton(): TypeScriptProcessor;
    createCodeGenerator(format: string): CodeGenerator;
}
export function createInstantiator(options: {
    imports: Imports;
}, swift: any): Promise<{
    addImports: (importObject: WebAssembly.Imports) => void;
    setInstance: (instance: WebAssembly.Instance) => void;
    createExports: (instance: WebAssembly.Instance) => Exports;
}>;