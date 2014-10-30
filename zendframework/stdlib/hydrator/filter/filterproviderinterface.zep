/*

This file is part of the php-ext-zendframework package.

For the full copyright and license information, please view the LICENSE
file that was distributed with this source code.

*/

namespace Zend\Stdlib\Hydrator\Filter;

interface FilterProviderInterface
{
    /**
     * Provides a filter for hydration
     *
     * @return FilterInterface
     */
    public function getFilter() -> <FilterInterface>;

}