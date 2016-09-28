package;

import kha.Color;
import kha.Framebuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CompareMode;
import kha.graphics4.CullMode;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.Shaders;
import kha.System;
import kha.Scheduler;

class Main {
	private static var pipeline: PipelineState;
	private static var vertices: VertexBuffer;
	private static var indices: IndexBuffer;
	
	private static var tessLevelInnerLocation: ConstantLocation;
	private static var tessLevelOuterLocation: ConstantLocation;
	private static var lightPositionLocation: ConstantLocation;
	private static var projectionLocation: ConstantLocation;
	private static var modelviewLocation: ConstantLocation;
	private static var normalMatrixLocation: ConstantLocation;
	private static var ambientMaterialLocation: ConstantLocation;
	private static var diffuseMaterialLocation: ConstantLocation;

	private static var tessLevelInner: Float = 3;
	private static var tessLevelOuter: Float = 2;

	public static function main(): Void {
		System.init({title: "Tessellation", width: 640, height: 480}, function () {
			var structure = new VertexStructure();
			structure.add("Position", VertexData.Float3);
			
			pipeline = new PipelineState();
			pipeline.inputLayout = [structure];
			pipeline.vertexShader = Shaders.test_vert;
			pipeline.fragmentShader = Shaders.test_frag;
			pipeline.geometryShader = Shaders.test_geom;
			pipeline.tessellationEvaluationShader = Shaders.test_tese;
			pipeline.tessellationControlShader = Shaders.test_tesc;
			pipeline.depthWrite = true;
			pipeline.depthMode = CompareMode.Less;
			pipeline.cullMode = CullMode.Clockwise;
			pipeline.compile();
			
			tessLevelInnerLocation = pipeline.getConstantLocation("TessLevelInner");
			tessLevelOuterLocation = pipeline.getConstantLocation("TessLevelOuter");
			lightPositionLocation = pipeline.getConstantLocation("LightPosition");
			projectionLocation = pipeline.getConstantLocation("Projection");
			modelviewLocation = pipeline.getConstantLocation("Modelview");
			normalMatrixLocation = pipeline.getConstantLocation("NormalMatrix");
			ambientMaterialLocation = pipeline.getConstantLocation("AmbientMaterial");
			diffuseMaterialLocation = pipeline.getConstantLocation("DiffuseMaterial");

			vertices = new VertexBuffer(12, structure, Usage.StaticUsage);
			var vdata = vertices.lock();
			var i = 0;
			vdata.set(i++, 0.000); vdata.set(i++, 0.000); vdata.set(i++, 1.000);
			vdata.set(i++, 0.894); vdata.set(i++, 0.000); vdata.set(i++, 0.447);
			vdata.set(i++, 0.276); vdata.set(i++, 0.851); vdata.set(i++, 0.447);
			vdata.set(i++, -0.724); vdata.set(i++, 0.526); vdata.set(i++, 0.447);
			vdata.set(i++, -0.724); vdata.set(i++, -0.526); vdata.set(i++, 0.447);
			vdata.set(i++, 0.276); vdata.set(i++, -0.851); vdata.set(i++, 0.447);
			vdata.set(i++, 0.724); vdata.set(i++, 0.526); vdata.set(i++, -0.447);
			vdata.set(i++, -0.276); vdata.set(i++, 0.851); vdata.set(i++, -0.447);
			vdata.set(i++, -0.894); vdata.set(i++, 0.000); vdata.set(i++, -0.447);
			vdata.set(i++, -0.276); vdata.set(i++, -0.851); vdata.set(i++, -0.447);
			vdata.set(i++, 0.724); vdata.set(i++, -0.526); vdata.set(i++, -0.447);
			vdata.set(i++, 0.000); vdata.set(i++, 0.000); vdata.set(i++, -1.000);
			vertices.unlock();

			indices = new IndexBuffer(20 * 3, Usage.StaticUsage);
			var idata = indices.lock();
			i = 0;
			idata[i++] = 2; idata[i++] = 1; idata[i++] = 0;
			idata[i++] = 3; idata[i++] = 2; idata[i++] = 0;
			idata[i++] = 4; idata[i++] = 3; idata[i++] = 0;
			idata[i++] = 5; idata[i++] = 4; idata[i++] = 0;
			idata[i++] = 1; idata[i++] = 5; idata[i++] = 0;
			idata[i++] = 11; idata[i++] = 6; idata[i++] = 7;
			idata[i++] = 11; idata[i++] = 7; idata[i++] = 8;
			idata[i++] = 11; idata[i++] = 8; idata[i++] = 9;
			idata[i++] = 11; idata[i++] = 9; idata[i++] = 10;
			idata[i++] = 11; idata[i++] = 10; idata[i++] = 6;
			idata[i++] = 1; idata[i++] = 2; idata[i++] = 6;
			idata[i++] = 2; idata[i++] = 3; idata[i++] = 7;
			idata[i++] = 3; idata[i++] = 4; idata[i++] = 8;
			idata[i++] = 4; idata[i++] = 5; idata[i++] = 9;
			idata[i++] = 5; idata[i++] = 1; idata[i++] = 10;
			idata[i++] = 2; idata[i++] = 7; idata[i++] = 6;
			idata[i++] = 3; idata[i++] = 8; idata[i++] = 7;
			idata[i++] = 4; idata[i++] = 9; idata[i++] = 8;
			idata[i++] = 5; idata[i++] = 10; idata[i++] = 9;
			idata[i++] = 1; idata[i++] = 6; idata[i++] = 10;
			indices.unlock();
			
			System.notifyOnRender(render);
		});
	}
	
	private static function render(frame: Framebuffer): Void {
		var g = frame.g4;
		g.begin();
		g.clear(Color.Black, 1.0);
		g.setPipeline(pipeline);
		g.setVertexBuffer(vertices);
		g.setIndexBuffer(indices);

		g.setFloat(tessLevelInnerLocation, tessLevelInner);
		g.setFloat(tessLevelOuterLocation, tessLevelOuter);
		g.setFloat3(lightPositionLocation, 0.25, 0.25, 1.0);
        g.setMatrix(projectionLocation, FastMatrix4.perspectiveProjection(Math.PI / 3, System.windowWidth() / System.windowHeight(), 5, 150));
		
		var rotation = FastMatrix4.rotationX(Scheduler.time());
		var eyePosition = new FastVector3(0.0, 0.0, -8.0);
		var targetPosition = new FastVector3(0.0, 0.0, 0.0);
		var upVector = new FastVector3(0.0, 1.0, 0.0);
		var lookAt = FastMatrix4.lookAt(eyePosition, targetPosition, upVector);
		var modelviewMatrix = lookAt.multmat(rotation);
		var normalMatrix = modelviewMatrix.transpose3x3();
		g.setMatrix(modelviewLocation, modelviewMatrix);
		g.setMatrix(normalMatrixLocation, normalMatrix);
		
		g.setFloat3(ambientMaterialLocation, 0.04, 0.04, 0.04);
		g.setFloat3(diffuseMaterialLocation, 0.0, 0.75, 0.75);

		g.drawIndexedVertices();
		g.end();
	}
}
