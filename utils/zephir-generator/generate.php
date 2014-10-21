<?php
/*
* This file is part of the php-ext-zf2 package.
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

require_once __DIR__ . '/common.php';

$dir = __DIR__ . '/../../vendor/zendframework/zendframework/library';
$dir = realpath($dir);
$dirTo = realpath(__DIR__ . '/../../');


$skipClasses = include __DIR__ . '/skip-classes.php';
$skipFiles = include __DIR__ . '/skip-files.php';
$skipNamespaces = include __DIR__ . '/skip-namespaces.php';

$allowClasses = include __DIR__ . '/allow-classes.php';
$allowNamespaces = include __DIR__ . '/allow-namespaces.php';

$iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dir, FilesystemIterator::SKIP_DOTS));
$regex = new RegexIterator($iterator, '/^.+\.php$/i', RecursiveRegexIterator::GET_MATCH);


foreach ($iterator as $k => $file) {
    /**
     * @var SplFileInfo $file
     */
    if ($file->getExtension() != 'php') {
        continue;
    }
    if(count(array_filter($skipFiles, function($skip) use ($file, $dir) {
        return $file->getPathname() == realpath($dir . '/'  . $skip);
    }))) {
        continue;
    }
    $path = dirname(substr($file->getPathname(), strlen($dir) + 1));
    $namespace = str_replace('/', '\\', $path);
    $classShortName = substr($file->getFilename(), 0, strlen($file->getFilename()) - 4);
    $path = strtolower($path);
    $file = $dirTo . '/' . $path . '/' . strtolower($classShortName) . '.zep';
    $className = $namespace . '\\' . $classShortName;

    if (!in_array($className, $allowClasses)) {
        $isAllowed = false;
        foreach($allowNamespaces as $allowNamespace) {
            if(0 === stripos($className, $allowNamespace)) {
                $isAllowed = true;
                break;
            }
        }
        if (!$isAllowed) {
            printf("Class %s not allowed!\n", $className);
            continue;
        }
    }

    if (!class_exists($className) &&
        !interface_exists($className) &&
        !trait_exists($className)
    ) {
        printf("Class %s not found!\n", $className);
        continue;
    }
    if(in_array($className, $skipClasses)) {
        printf("Class %s skipped!\n", $className);
        continue;
    } else {
        $isSkipped = false;
        foreach($skipNamespaces as $skipNamespace) {
            if(0 === stripos($className, $skipNamespace)) {
                $isSkipped = true;
                break;
            }
        }
        if ($isSkipped) {
            printf("Class %s skipped!\n", $className);
            continue;
        }
    }

    $ref = new \ReflectionClass($className);
    if ($ref->isTrait()) {
        continue; // not supported
    }

    $content = "/*
* This file is part of the php-ext-zf2 package.
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/
\nnamespace $namespace;\n\n";

    if($doc = $ref->getDocComment()) {
        $content .= $doc . "\n";
    }
    if ($ref->isInterface()) {
        $content .= "interface {$ref->getShortName()}";

        $interfaces = $ref->getInterfaces();
        if(count($interfaces)) {
            $content .= ' extends ';
        }
        $fi = true;
        foreach ($ref->getInterfaces() as $interface) {
            if (!$fi) {
                $content .= ', ';
            }
            if ($interface->inNamespace()) {
                if ($ref->getNamespaceName() == $interface->getNamespaceName()) {
                    $content .= $interface->getShortName();
                } elseif (0 === stripos($interface->getNamespaceName(), $ref->getNamespaceName())) {
                    $content .= substr($interface->getName(), strlen($ref->getNamespaceName()));
                } else {
                    $content .= '\\' . $interface->getName();
                }
            } else {
                $content .= '\\' . $interface->getName();
            }
            $fi = false;
        }
    } else {
        if ($ref->isFinal()) {
            $content .= "final ";
        } elseif ($ref->isAbstract()) {
            $content .= "abstract ";
        }
        $content .= "class {$ref->getShortName()}";

        if($parent = $ref->getParentClass()) {
            $content .= ' extends ';
            if ($parent->inNamespace()) {
                if ($ref->getNamespaceName() == $parent->getNamespaceName()) {
                    $content .= $parent->getShortName();
                } elseif (0 === stripos($parent->getNamespaceName(), $ref->getNamespaceName())) {
                    $content .= substr($parent->getName(), strlen($ref->getNamespaceName()));
                } else {
                    $content .= '\\' . $parent->getName();
                }
            } else {
                $content .= '\\' . $parent->getName();
            }
        }

        $interfaces = $ref->getInterfaces();
        if(count($interfaces)) {
            $content .= ' implements ';
        }
        $fi = true;
        foreach ($ref->getInterfaces() as $interface) {
            if (!$fi) {
                $content .= ', ';
            }
            if ($interface->inNamespace()) {
                if ($ref->getNamespaceName() == $interface->getNamespaceName()) {
                    $content .= $interface->getShortName();
                } elseif (0 === stripos($interface->getNamespaceName(), $ref->getNamespaceName())) {
                    $content .= substr($interface->getName(), strlen($ref->getNamespaceName()));
                } else {
                    $content .= '\\' . $interface->getName();
                }
            } else {
                $content .= '\\' . $interface->getName();
            }
            $fi = false;
        }
    }

    $content .= "\n{";

    // constants
    foreach($ref->getConstants() as $constantName => $constantValue) {
        $content .= "\n" . zephir_generate_constant($constantName, $constantValue) . "\n";
    }

    // properties
    foreach($ref->getProperties() as $property) {
        if($property->getDeclaringClass()->getName() != $ref->getName()) {
            continue;
        }
        $content .= "\n" . zephir_generate_property($property) . "\n";
    }

    // methods
    foreach($ref->getMethods() as $method) {
        if($method->getDeclaringClass()->getName() != $ref->getName()) {
            continue;
        }
        $content .= "\n" . zephir_generate_method($method) . "\n";
    }

    $content .= "\n}\n";

    if (!is_dir($dirTo . '/' . $path)) {
        mkdir($dirTo . '/' . $path, 0755, true);
    }
    file_put_contents($file, $content);
}


$content = "\n\nnamespace $namespace;\n";


