/*

This file is part of the php-ext-zendframework package.

For the full copyright and license information, please view the LICENSE
file that was distributed with this source code.

*/

namespace Zend\Loader;

use ArrayIterator;
use IteratorAggregate;
use Traversable;

/**
 * Plugin class locator interface
 */
class PluginClassLoader implements PluginClassLocator
{
    /**
     * List of plugin name => class name pairs
     * @var array
     */
    protected plugins = [];

    /**
     * Static map allow global seeding of plugin loader
     * @var array
     */
    protected static staticMap; // []

    /**
     * Constructor
     *
     * @param null|array|Traversable map If provided, seeds the loader with a map
     */
    public function __construct(var map = null)
    {
        var staticMap = null, className;

        let className = get_called_class();
        %{
            zephir_read_static_property(&staticMap, Z_STRVAL_P(className), Z_STRLEN_P(className), SL("staticMap") TSRMLS_CC);
        }%
        // Merge in static overrides
        if !empty staticMap {
            this->registerPlugins(staticMap);
        }
        // Merge in constructor arguments
        if map !== null {
            this->registerPlugins(map);
        }
    }

    /**
     * Add a static map of plugins
     *
     * A null value will clear the static map.
     *
     * @param  null|array|Traversable map
     * @throws Exception\InvalidArgumentException
     * @return void
     */
    public static function addStaticMap(var map) -> void
    {
        var staticMap = null, className, key, value;

        let className = get_called_class();
        if map === null {
            %{
                zephir_update_static_property(Z_STRVAL_P(className), Z_STRLEN_P(className), SL("staticMap"), &staticMap TSRMLS_CC);
            }%
            return;
        }

        if unlikely typeof map != "array" && !(map instanceof Traversable) {
            throw new Exception\InvalidArgumentException("Expects an array or Traversable object");
        }
        %{
            zephir_read_static_property(&staticMap, Z_STRVAL_P(className), Z_STRLEN_P(className), SL("staticMap") TSRMLS_CC);
        }%
        if typeof staticMap != "array" {
            let staticMap = [];
        }

        for key, value in map {
            let staticMap[key] = value;
        }
        %{
            zephir_update_static_property(Z_STRVAL_P(className), Z_STRLEN_P(className), SL("staticMap"), &staticMap TSRMLS_CC);
        }%
    }

    /**
     * Register a class to a given short name
     *
     * @param  string shortName
     * @param  string className
     * @return PluginClassLoader
     */
    public function registerPlugin(string shortName, string className) -> <PluginClassLoader>
    {
        let shortName = shortName->lower();
        let this->plugins[shortName] = className;

        return this;
    }

    /**
     * Register many plugins at once
     *
     * If $map is a string, assumes that the map is the class name of a
     * Traversable object (likely a ShortNameLocator); it will then instantiate
     * this class and use it to register plugins.
     *
     * If $map is an array or Traversable object, it will iterate it to
     * register plugin names/classes.
     *
     * For all other arguments, or if the string $map is not a class or not a
     * Traversable class, an exception will be raised.
     *
     * @param  string|array|Traversable $map
     * @return PluginClassLoader
     * @throws Exception\InvalidArgumentException
     */
    public function registerPlugins(var map) -> <PluginClassLoader>
    {
        var name, className;

        if typeof map == "string" {
            if unlikely !class_exists(map) {
                throw new Exception\InvalidArgumentException("Map class provided is invalid");
            }
            let map = new {map}();
        } elseif typeof map == "array" {
            let map = new ArrayIterator(map);
        }

        if unlikely !(map instanceof Traversable) {
            throw new Exception\InvalidArgumentException("Map provided is invalid; must be traversable");
        }

        for name, className in iterator(map) {
            if typeof name == "integer" || is_numeric(name) {
                if typeof className != "object" && class_exists(className) {
                    let className = new {className}();
                }
                if className instanceof Traversable {
                    this->registerPlugins(className);
                    continue;
                }
            }
            this->registerPlugin(name, className);
        }
        return this;
    }

    /**
     * Unregister a short name lookup
     *
     * @param  mixed $shortName
     * @return PluginClassLoader
     */
    public function unregisterPlugin(var shortName) -> <PluginClassLoader>
    {
        var lookup, plugins;

        let lookup = strtolower(shortName);
        let plugins = this->plugins;

        if array_key_exists(lookup, plugins) {
            unset this->plugins[lookup];
        }

        return this;
    }

    /**
     * Get a list of all registered plugins
     *
     * @return array|Traversable
     */
    public function getRegisteredPlugins() -> array|<\Traversable>
    {
        return this->plugins;
    }

    /**
     * Whether or not a plugin by a specific name has been registered
     *
     * @param  string $name
     * @return bool
     */
    public function isLoaded(string name) -> boolean
    {
        string lookup;
        let lookup = name->lower();

        return isset this->plugins[lookup];
    }

    /**
     * Return full class name for a named helper
     *
     * @param  string $name
     * @return string|false
     */
    public function getClassName(string name) -> string|boolean
    {
        var className;
        let className = this->load(name);

        return className;
    }

    /**
     * Load a helper via the name provided
     *
     * @param  string $name
     * @return string|false
     */
    public function load(string name) -> string|boolean
    {
        var className, lookup;

        if !this->isLoaded(name) {
            return false;
        }
        let lookup = name->lower();
        if fetch className, this->plugins[lookup] {
            return className;
        }
        return false;
    }

    /**
     * Defined by IteratorAggregate
     *
     * Returns an instance of ArrayIterator, containing a map of
     * all plugins
     *
     * @return ArrayIterator
     */
    public function getIterator() -> <\ArrayIterator>
    {
        var plugins, iterator;
        
        let plugins = this->plugins;
        let iterator = new ArrayIterator(plugins);

        return iterator;
    }

}
