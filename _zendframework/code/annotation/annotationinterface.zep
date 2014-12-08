/*

This file is part of the php-ext-zendframework package.

For the full copyright and license information, please view the LICENSE
file that was distributed with this source code.

*/

namespace Zend\Code\Annotation;

interface AnnotationInterface
{
    /**
     * Initialize
     *
     * @param  string $content
     * @return void
     */
    public function initialize(string content) -> void;

}