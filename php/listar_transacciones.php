<?php
require_once '../config/conexion.php';

$sql = "SELECT t.id_transaccion, t.tipo, t.monto, t.moneda, t.fecha, t.estado,
               co.alias AS origen, cd.alias AS destino, t.descripcion
        FROM transaccion t
        LEFT JOIN cuenta co ON co.id_cuenta = t.id_cuenta_origen
        LEFT JOIN cuenta cd ON cd.id_cuenta = t.id_cuenta_destino
        ORDER BY t.fecha DESC";
$resultado = $conexion->query($sql);

include '../includes/header.php';
?>

<h2>Transacciones</h2>

<table>
    <tr>
        <th>ID</th>
        <th>Tipo</th>
        <th>Origen</th>
        <th>Destino</th>
        <th>Monto</th>
        <th>Moneda</th>
        <th>Fecha</th>
        <th>Estado</th>
        <th>Descripción</th>
    </tr>
    <?php while ($fila = $resultado->fetch_assoc()): ?>
    <tr>
        <td><?php echo $fila['id_transaccion']; ?></td>
        <td><?php echo $fila['tipo']; ?></td>
        <td><?php echo $fila['origen']; ?></td>
        <td><?php echo $fila['destino']; ?></td>
        <td>$<?php echo number_format($fila['monto'], 2, ',', '.'); ?></td>
        <td><?php echo $fila['moneda']; ?></td>
        <td><?php echo $fila['fecha']; ?></td>
        <td><?php echo $fila['estado']; ?></td>
        <td><?php echo $fila['descripcion']; ?></td>
    </tr>
    <?php endwhile; ?>
</table>

<?php
$conexion->close();
include '../includes/footer.php';
?>