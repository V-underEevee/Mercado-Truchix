<?php
require_once '../config/conexion.php';

$sql = "SELECT id_usuario, nombre, apellido, dni, email, telefono, estado FROM usuario ORDER BY id_usuario";
$resultado = $conexion->query($sql);

include '../includes/header.php';
?>

<h2>Usuarios registrados</h2>

<table>
    <tr>
        <th>ID</th>
        <th>Nombre</th>
        <th>Apellido</th>
        <th>DNI</th>
        <th>Email</th>
        <th>Teléfono</th>
        <th>Estado</th>
    </tr>
    <?php while ($fila = $resultado->fetch_assoc()): ?>
    <tr>
        <td><?php echo $fila['id_usuario']; ?></td>
        <td><?php echo $fila['nombre']; ?></td>
        <td><?php echo $fila['apellido']; ?></td>
        <td><?php echo $fila['dni']; ?></td>
        <td><?php echo $fila['email']; ?></td>
        <td><?php echo $fila['telefono']; ?></td>
        <td><?php echo $fila['estado']; ?></td>
    </tr>
    <?php endwhile; ?>
</table>

<?php
$conexion->close();
include '../includes/footer.php';
?>