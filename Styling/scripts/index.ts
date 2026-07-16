import 'regenerator-runtime/runtime';
import './../styles/styles.css';

// Syntax highlighting (client-side, replaces the removed Splash plugin) and
// Mermaid diagrams. Ink renders fenced code blocks as
// `<pre><code class="language-xxx">…</code></pre>`, which is exactly what
// highlight.js targets and what the Mermaid transform below looks for.
import hljs from 'highlight.js/lib/core';
import swift from 'highlight.js/lib/languages/swift';
import yaml from 'highlight.js/lib/languages/yaml';
import bash from 'highlight.js/lib/languages/bash';
import ini from 'highlight.js/lib/languages/ini'; // also covers `toml`
import mermaid from 'mermaid';
// highlight.js token colors are defined in styles/styles.css (`.hljs-*` rules),
// so the site keeps its own palette instead of a prebuilt hljs theme.

hljs.registerLanguage('swift', swift);
hljs.registerLanguage('yaml', yaml);
hljs.registerLanguage('bash', bash);
hljs.registerLanguage('ini', ini);
hljs.registerLanguage('toml', ini);

const languageClassPattern = /\blang(?:uage)?-([\w-]+)\b/i;

// Turn Ink's `<pre><code class="language-mermaid">` blocks into the
// `<div class="mermaid">` elements Mermaid renders, then run Mermaid. Bails
// early when there are no diagrams so the library only initializes when needed.
function renderMermaidDiagrams(): void {
    const blocks = document.querySelectorAll<HTMLElement>('pre > code.language-mermaid');
    if (blocks.length === 0) {
        return;
    }
    blocks.forEach((code) => {
        const pre = code.parentElement!;
        const div = document.createElement('div');
        div.className = 'mermaid';
        // `textContent` decodes the HTML entities Ink escaped in the source.
        div.textContent = code.textContent ?? '';
        pre.replaceWith(div);
    });
    mermaid.initialize({
        startOnLoad: false,
        theme: window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default',
    });
    void mermaid.run();
}

function explicitLanguageName(block: HTMLElement): string | null {
    const classNames = `${block.className} ${block.parentElement?.className ?? ''}`;
    return languageClassPattern.exec(classNames)?.[1] ?? null;
}

// Highlight every fenced code block except Mermaid diagrams, blocks the author
// opted out of with ```no-highlight, and unsupported explicit language labels.
function highlightCodeBlocks(): void {
    document
        .querySelectorAll<HTMLElement>('pre code')
        .forEach((block) => {
            if (
                block.classList.contains('language-mermaid') ||
                block.classList.contains('language-no-highlight')
            ) {
                return;
            }
            const languageName = explicitLanguageName(block);
            if (languageName && !hljs.getLanguage(languageName)) {
                return;
            }
            hljs.highlightElement(block);
        });
}

declare global {
    interface Window {
        gtag: (...args: any[]) => void
        dataLayer: Record<string, any>
    }
}

let isShare: Boolean = true
isShare = isShare && !!navigator.canShare
isShare = isShare && !!navigator.share
isShare = isShare && navigator.canShare({
    text: "EmpowerApps.Show",
    url: "https://brightdigit.com/episodes/"
})

const canClipboardItem = (typeof ClipboardItem !== "undefined")

function updateMaskIcon(darkMode?: Boolean) {

    const isDarkMode = darkMode ?? window.matchMedia('(prefers-color-scheme: dark)').matches
    const maskIcon = document.getElementById("mask-icon")
    const lightModeHref = document.getElementById("apple-light-mode-icon")?.getAttribute("href")
    const darkModeHref = document.getElementById("apple-dark-mode-icon")?.getAttribute("href")
    if (isDarkMode && typeof darkModeHref == 'string') {
        maskIcon?.setAttribute("href", darkModeHref)
        maskIcon?.setAttribute("color", "#f9e231")
    } else if (typeof lightModeHref == 'string') {
        maskIcon?.setAttribute("href", lightModeHref)
        maskIcon?.setAttribute("color", "#000000")
    }
}

window.onload = () => {
    const menuButton = document.getElementById('menu')
    const main = document.body.getElementsByTagName("main")[0]
    const navMenu = document.querySelector("body > header > nav") as HTMLElement
    let menuOffsetHeight: Number
    document.body.addEventListener('transitionend', (event) => {

        if (document.body.classList.contains('end-active')) {
            document.body.classList.remove('more-active')
            document.body.classList.remove('end-active')
            main.style.top = `${menuOffsetHeight}px`
        }
    })
    menuButton?.addEventListener("click", () => {
        if (document.body.classList.contains('more-active')) {
            document.body.classList.add('end-active')
        } else {
            menuOffsetHeight = navMenu.offsetHeight
            main.style.top = `${menuOffsetHeight}px`
            document.body.classList.add('more-active')
        }
    })
    updateMaskIcon()
}

window.matchMedia('(prefers-color-scheme: dark)')
    .addEventListener('change', (event) => {
        updateMaskIcon(event.matches)
    })

window.document.addEventListener("DOMContentLoaded", () => {
    // Mermaid first, so its blocks are removed before highlight.js runs.
    renderMermaidDiagrams()
    highlightCodeBlocks()

    const shareLinks = document.querySelectorAll("a[data-text][data-url]")
    const type = "text/html";
    shareLinks.forEach(element => {
        const htmlElement = <HTMLElement>element
        const text = htmlElement.dataset['text']
        const url = htmlElement.dataset['url']
        if (text && url) {
            const data = {
                text,
                url
            }
            const cptext = `<a href="${url}">${text}</a>`
            const blob = new Blob([cptext], { type });
            const textType = "text/plain";
            const textBlob = new Blob([url], { type: textType });
            let cpdata: ([any] | null) = null
            if (canClipboardItem) {
                cpdata = [
                    new ClipboardItem({ [type]: blob, [textType]: textBlob })
                ];
            }

            if (!isShare) {
                element.innerHTML = '<i class="flaticon-clipboard"></i> Copy'
            }
            htmlElement.style.cursor = "pointer"
            htmlElement.style.textDecoration = "none"
            element.addEventListener("click", async (evt) => {
                evt.preventDefault()
                const mouseEvent = <MouseEvent>evt;
                if (!mouseEvent.altKey && isShare) {
                    try {

                        await navigator.share(data)
                        return false

                    }
                    catch (error) {
                        if (error instanceof AbortError) {
                            evt.preventDefault()
                            return false
                        }
                        console.error(error)
                        
                    }
                }
                try {
                    if (cpdata) {
                        await navigator.clipboard.write(cpdata)
                    } else {
                        await navigator.clipboard.writeText(cptext)
                    }
                } catch (error) {
                    console.error(error)
                    window.location.href = htmlElement.getAttribute("href") ?? url
                }
                return false
            }, false)
        }
    })
});


window.dataLayer = window.dataLayer || [];
function gtag() { window.dataLayer.push(arguments); }
gtag('js', new Date());
gtag('config', 'G-K3MSJ0CTMJ');
