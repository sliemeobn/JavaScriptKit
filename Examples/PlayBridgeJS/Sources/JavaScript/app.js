// @ts-check
import { EditorSystem } from './editor.js';
import ts from 'typescript';
import { TypeProcessor } from './processor.js';
import { CodeShareManager } from './code-share.js';
import {
  createSystem,
  createDefaultMapFromCDN,
  createVirtualCompilerHost
} from '@typescript/vfs';

/**
 * @typedef {import('../../.build/plugins/PackageToJS/outputs/Package/bridge-js.js').PlayBridgeJS} PlayBridgeJS
 */

/**
 * The main controller for the BridgeJS Playground.
 */
export class BridgeJSPlayground {
    /**
     * Creates a new instance of the BridgeJSPlayground.
     */
    constructor() {
        this.editorSystem = new EditorSystem();
        /** @type {PlayBridgeJS | null} */
        this.playBridgeJS = null;
        /** @type {ReturnType<typeof setTimeout> | null} */
        this.generateTimeout = null;
        /** @type {boolean} */
        this.isInitialized = false;

        /** @type {HTMLDivElement} */
        this.errorDisplay = /** @type {HTMLDivElement} */ (document.getElementById('errorDisplay'));
        /** @type {HTMLDivElement} */
        this.errorMessage = /** @type {HTMLDivElement} */ (document.getElementById('errorMessage'));
        /** @type {HTMLButtonElement} */
        this.shareButton = /** @type {HTMLButtonElement} */ (document.getElementById('shareButton'));
        /** @type {HTMLDialogElement} */
        this.shareDialog = /** @type {HTMLDialogElement} */ (document.getElementById('shareDialog'));
        /** @type {HTMLInputElement} */
        this.shareUrlInput = /** @type {HTMLInputElement} */ (document.getElementById('shareUrl'));
        /** @type {HTMLButtonElement} */
        this.copyButton = /** @type {HTMLButtonElement} */ (document.getElementById('copyButton'));
        /** @type {HTMLButtonElement} */
        this.closeShareDialogButton = /** @type {HTMLButtonElement} */ (document.getElementById('closeShareDialog'));
    }

    /**
     * Initializes the application.
     * @param {{swift: string, dts: string}} sampleCode - The sample code to initialize the application with.
     */
    async initialize(sampleCode) {
        if (this.isInitialized) {
            return;
        }

        try {
            // Initialize editor system
            await this.editorSystem.init();

            // Initialize BridgeJS
            await this.initializeBridgeJS();

            // Set up event listeners
            this.setupEventListeners();

            // Check for shared code in URL
            const sharedCode = await CodeShareManager.extractCodeFromUrl();
            if (sharedCode) {
                this.editorSystem.setInputs(sharedCode);
            } else {
                // Load sample code
                this.editorSystem.setInputs(sampleCode);
            }

            this.isInitialized = true;
            console.log('BridgeJS Playground initialized successfully');
        } catch (error) {
            console.error('Failed to initialize BridgeJS Playground:', error);
            this.showError('Failed to initialize application: ' + error.message);
        }
    }

    // Initialize BridgeJS
    async initializeBridgeJS() {
        try {
            // Import the BridgeJS module
            const { init } = await import("../../.build/plugins/PackageToJS/outputs/Package/index.js");
            const virtualHost = await this.createTS2SkeletonFactory();
            const { exports } = await init({
                getImports: () => ({
                    createTS2Skeleton: () => this.createTS2Skeleton(virtualHost)
                })
            });
            this.playBridgeJS = new exports.PlayBridgeJS();
            console.log('BridgeJS initialized successfully');
        } catch (error) {
            console.error('Failed to initialize BridgeJS:', error);
            throw new Error('BridgeJS initialization failed: ' + error.message);
        }
    }

    // Set up event listeners
    setupEventListeners() {
        // Add change listeners for real-time generation
        this.editorSystem.addChangeListeners(() => {
            // Debounce generation to avoid excessive calls
            if (this.generateTimeout) {
                clearTimeout(this.generateTimeout);
            }
            this.generateTimeout = setTimeout(() => this.generateCode(), 300);
        });

        // Set up share functionality
        this.setupShareListeners();
    }

    // Set up share-related event listeners
    setupShareListeners() {
        // Show share dialog
        this.shareButton.addEventListener('click', async () => {
            try {
                const inputs = this.editorSystem.getInputs();
                const shareUrl = await CodeShareManager.generateShareUrl(inputs);
                this.shareUrlInput.value = shareUrl;
                this.shareDialog.classList.remove('hidden');
                this.shareUrlInput.select();
            } catch (error) {
                console.error('Failed to generate share URL:', error);
                this.showError('Failed to generate share URL: ' + error.message);
            }
        });

        // Copy share URL
        this.copyButton.addEventListener('click', async () => {
            try {
                await navigator.clipboard.writeText(this.shareUrlInput.value);

                const originalText = this.copyButton.textContent;
                this.copyButton.textContent = 'Copied!';
                this.copyButton.classList.add('copied');

                setTimeout(() => {
                    this.copyButton.textContent = originalText;
                    this.copyButton.classList.remove('copied');
                }, 2000);
            } catch (error) {
                console.error('Failed to copy URL:', error);
                this.shareUrlInput.select();
            }
        });

        // Close share dialog
        this.closeShareDialogButton.addEventListener('click', () => {
            this.shareDialog.classList.add('hidden');
        });

        // Close dialog when clicking outside
        document.addEventListener('click', (event) => {
            if (!this.shareDialog.classList.contains('hidden')) {
                const dialogContent = this.shareDialog.querySelector('.share-dialog-content');
                const target = event.target;
                if (dialogContent && target instanceof Node && !dialogContent.contains(target) &&
                    this.shareButton && !this.shareButton.contains(target)) {
                    this.shareDialog.classList.add('hidden');
                }
            }
        });

        // Close dialog with Escape key
        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape' && !this.shareDialog.classList.contains('hidden')) {
                this.shareDialog.classList.add('hidden');
            }
        });
    }

    async createTS2SkeletonFactory() {
        const createVirtualHost = async () => {
          const fsMap = await createDefaultMapFromCDN(
            { target: ts.ScriptTarget.ES2015 },
            ts.version,
            true,
            ts
          );

          const system = createSystem(fsMap);

          const compilerOptions = {
            target: ts.ScriptTarget.ES2015,
            lib: ["es2015", "dom"],
          };

          return createVirtualCompilerHost(system, compilerOptions, ts);
        }
        return await createVirtualHost();
    }

    /**
     * @param {ReturnType<typeof createVirtualCompilerHost>} virtualHost
     */
    createTS2Skeleton(virtualHost) {
        return {
            /**
             * @param {string} dtsCode
             * @returns {string}
             */
            convert: (dtsCode) => {
                // Create TypeScript program from d.ts content
                const virtualFilePath = "bridge-js.d.ts"
                const sourceFile = ts.createSourceFile(virtualFilePath, dtsCode, ts.ScriptTarget.ES2015);
                virtualHost.updateFile(sourceFile);
                const tsProgram = ts.createProgram({
                    rootNames: [virtualFilePath],
                    host: virtualHost.compilerHost,
                    options: {
                        noEmit: true,
                        declaration: true,
                    }
                })

                // Create diagnostic engine for error reporting
                const diagnosticEngine = {
                    print: (level, message, node) => {
                        console.log(`[${level}] ${message}`);
                        if (level === 'error') {
                            this.showError(`TypeScript Error: ${message}`);
                        }
                    }
                };

                // Process the TypeScript definitions to generate skeleton
                const processor = new TypeProcessor(tsProgram.getTypeChecker(), diagnosticEngine);

                const skeleton = processor.processTypeDeclarations(tsProgram, virtualFilePath);

                return JSON.stringify(skeleton);
            }
        }
    }

    /**
     * Generates code through BridgeJS.
     */
    async generateCode() {
        if (!this.playBridgeJS) {
            this.showError('BridgeJS is not initialized');
            return;
        }

        try {
            this.hideError();

            const inputs = this.editorSystem.getInputs();
            const swiftCode = inputs.swift;
            const dtsCode = inputs.dts;

            // Process the code and get PlayBridgeJSOutput
            const result = this.playBridgeJS.update(swiftCode, dtsCode);

            // Update outputs using the PlayBridgeJSOutput object
            this.editorSystem.updateOutputs(result);

            console.log('Code generated successfully');

        } catch (error) {
            console.error('Error generating code:', error);
            this.showError('Error generating code: ' + error.message);
        }
    }

    /**
     * Shows an error message.
     * @param {string} message - The message to show.
     */
    showError(message) {
        this.errorMessage.textContent = message;
        this.errorDisplay.classList.add('show');
    }

    /**
     * Hides the error message.
     */
    hideError() {
        this.errorDisplay.classList.remove('show');
    }
}