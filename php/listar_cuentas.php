<?php
require_once '../config/conexion.php';

$sql = "SELECT c.id_cuenta, c.alias, c.cvu, c.saldo, c.moneda, c.estado,
               CONCAT(u.nombre, ' ', u.apellido) AS titular
        FROM cuenta c
        JOIN usuario u ON u.id_usuario = c.id_usuario
        ORDER BY c.saldo DESC";
$resultado = $conexion->query($sql);

include '../includes/header.php';
?>

<h2>Cuentas</h2>

<table>
    <tr>
        <th>ID</th>
        <th>Alias</th>
        <th>CVU</th>
        <th>Titular</th>
        <th>Saldo</th>
        <th>Moneda</th>
        <th>Estado</th>
    </tr>
    <?php while ($fila = $resultado->fetch_assoc()): ?>
    <tr>
        <td><?php echo $fila['id_cuenta']; ?></td>
        <td><?php echo $fila['alias']; ?></td>
        <td><?php echo $fila['cvu']; ?></td>
        <td><?php echo $fila['titular']; ?></td>
        <td>$<?php echo number_format($fila['saldo'], 2, ',', '.'); ?></td>
        <td><?php echo $fila['moneda']; ?></td>
        <td><?php echo $fila['estado']; ?></td>
    </tr>
    <?php endwhile; ?>
</table>

<?php
$conexion->close();
include '../includes/footer.php';
?>