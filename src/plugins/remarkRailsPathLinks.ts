import type { Root, InlineCode } from 'mdast';
import { visit } from 'unist-util-visit';

// rails path patterns
const RAILS_PATH_PATTERN = /^(app|db|config|test)\/.+$/;

export interface RailsPathLinkOptions {
  className?: string;
}

const remarkRailsPathLinks = (options: RailsPathLinkOptions = {}) => {
  const className = options.className || 'rails-path-link';

  return (tree: Root) => {
    visit(tree, 'inlineCode', (node: InlineCode, index, parent) => {
      if (!parent || typeof index !== 'number') {
        return;
      }

      // check if the inline code content matches Rails path pattern
      const content = node.value;

      if (!RAILS_PATH_PATTERN.test(content)) {
        return;
      }

      // replace the inline code node with an HTML node containing a link
      const htmlNode = {
        type: 'html',
        value: `<button class="${className}" data-rails-path="${content}"><code>${content}</code></button>`,
      };

      parent.children[index] = htmlNode as any;
    });
  };
};

export default remarkRailsPathLinks;
