
namespace Zend\Stdlib;

interface MessageInterface
{
    /**
     * Set metadata
     *
     * @param  string|int|array|\Traversable $spec
     * @param  mixed $value
     */
    public function setMetadata(var spec, var value = null);

    /**
     * Get metadata
     *
     * @param  null|string|int $key
     * @return mixed
     */
    public function getMetadata(var key = null);

    /**
     * Set content
     *
     * @param  mixed $content
     * @return mixed
     */
    public function setContent(var content);

    /**
     * Get content
     *
     * @return mixed
     */
    public function getContent();

}
